{-# LANGUAGE LambdaCase #-}
module Language.Drasil.Code.ExternalLibrary (ExternalLibrary, Step,
  FunctionInterface, Argument, externalLib, choiceSteps, choiceStep, 
  mandatoryStep, mandatorySteps, callStep, callRequiresJust, callRequires, 
  libFunction, libMethod, libFunctionWithResult, libMethodWithResult, 
  libConstructor, constructAndReturn, lockedArg, lockedNamedArg, inlineArg, 
  inlineNamedArg, preDefinedArg, preDefinedNamedArg, functionArg, customObjArg, 
  recordArg, lockedParam, unnamedParam, customClass, implementation, 
  constructorInfo, methodInfo, appendCurrSol, populateSolList, 
  assignArrayIndex, assignSolFromObj, initSolListFromArray, initSolListWithVal, 
  solveAndPopulateWhile, returnExprList, fixedReturn
) where

import Language.Drasil
import Language.Drasil.Chunk.Code (CodeChunk, codeType, ccObjVar)
import Language.Drasil.Mod (FuncStmt(..))

import GOOL.Drasil (CodeType)

import Data.List.NonEmpty (NonEmpty(..), fromList)

type Description = String
type Condition = Expr
type Requires = String

type ExternalLibrary = [StepGroup]

type StepGroup = NonEmpty [Step]

data Step = Call [Requires] FunctionInterface
  -- A while loop -- function calls in the condition, other conditions, steps for the body
  | Loop (NonEmpty FunctionInterface) ([Expr] -> Condition) (NonEmpty Step)
  -- For when a statement is needed, but does not interface with the external library
  | Statement ([CodeChunk] -> [Expr] -> FuncStmt)

data FunctionInterface = FI FuncType CodeChunk [Argument] (Maybe Result)

data Result = Assign CodeChunk | Return 

data Argument = Arg (Maybe CodeChunk) ArgumentInfo -- Maybe named argument

data ArgumentInfo = 
  -- Not dependent on use case, Maybe is name for the argument
  LockedArg Expr 
  -- Maybe is the variable if it needs to be declared and defined prior to calling
  | Basic CodeType (Maybe CodeChunk) 
  | Fn CodeChunk [Parameter] Step
  | Class [Requires] Description CodeChunk ClassInfo
  -- constructor, object, fields
  | Record CodeChunk CodeChunk [CodeChunk]

data Parameter = LockedParam CodeChunk | NameableParam CodeType

data ClassInfo = Regular [MethodInfo] | Implements String [MethodInfo]

-- Constructor, known parameters, body
data MethodInfo = CI CodeChunk [Parameter] [Step]
  -- Method, known parameters, body
  | MI CodeChunk [Parameter] (NonEmpty Step)

data FuncType = Function | Method CodeChunk | Constructor

externalLib :: [StepGroup] -> ExternalLibrary
externalLib = id

choiceSteps :: [[Step]] -> StepGroup
choiceSteps [] = error "choiceSteps should be called with a non-empty list"
choiceSteps sg = fromList sg

choiceStep :: [Step] -> StepGroup
choiceStep [] = error "choiceStep should be called with a non-empty list"
choiceStep ss = fromList $ map (: []) ss

mandatoryStep :: Step -> StepGroup
mandatoryStep f = [f] :| []

mandatorySteps :: [Step] -> StepGroup
mandatorySteps fs = fs :| []

callStep :: FunctionInterface -> Step
callStep = Call []

callRequiresJust :: Requires -> FunctionInterface -> Step
callRequiresJust i = Call [i]

callRequires :: [Requires] -> FunctionInterface -> Step
callRequires = Call

loopStep :: [FunctionInterface] -> ([Expr] -> Condition) -> [Step] -> Step
loopStep [] _ _ = error "loopStep should be called with a non-empty list of FunctionInterface"
loopStep _ _ [] = error "loopStep should be called with a non-empty list of Step"
loopStep fis c ss = Loop (fromList fis) c (fromList ss)

libFunction :: CodeChunk -> [Argument] -> FunctionInterface
libFunction f ps = FI Function f ps Nothing

libMethod :: CodeChunk -> CodeChunk -> [Argument] -> FunctionInterface
libMethod o m ps = FI (Method o) m ps Nothing

libFunctionWithResult :: CodeChunk -> [Argument] -> CodeChunk -> 
  FunctionInterface
libFunctionWithResult f ps r = FI Function f ps (Just $ Assign r)

libMethodWithResult :: CodeChunk -> CodeChunk -> [Argument] -> CodeChunk -> 
  FunctionInterface
libMethodWithResult o m ps r = FI (Method o) m ps (Just $ Assign r)

libConstructor :: CodeChunk -> [Argument] -> CodeChunk -> FunctionInterface
libConstructor c as r = FI Constructor c as (Just $ Assign r)

constructAndReturn :: CodeChunk -> [Argument] -> FunctionInterface
constructAndReturn c as = FI Constructor c as (Just Return)

lockedArg :: Expr -> Argument
lockedArg = Arg Nothing . LockedArg

lockedNamedArg :: CodeChunk -> Expr -> Argument
lockedNamedArg n = Arg (Just n) . LockedArg

inlineArg :: CodeType -> Argument
inlineArg t = Arg Nothing $ Basic t Nothing

inlineNamedArg :: CodeChunk ->  CodeType -> Argument
inlineNamedArg n t = Arg (Just n) $ Basic t Nothing

preDefinedArg :: CodeChunk -> Argument
preDefinedArg v = Arg Nothing $ Basic (codeType v) (Just v)

preDefinedNamedArg :: CodeChunk -> CodeChunk -> Argument
preDefinedNamedArg n v = Arg (Just n) $ Basic (codeType v) (Just v)

functionArg :: CodeChunk -> [Parameter] -> Step -> Argument
functionArg f ps b = Arg Nothing (Fn f ps b)

customObjArg :: [Requires] -> Description -> CodeChunk -> ClassInfo -> Argument
customObjArg rs d o ci = Arg Nothing (Class rs d o ci)

recordArg :: CodeChunk -> CodeChunk -> [CodeChunk] -> Argument
recordArg c o fs = Arg Nothing (Record c o fs)

lockedParam :: CodeChunk -> Parameter
lockedParam = LockedParam

unnamedParam :: CodeType -> Parameter
unnamedParam = NameableParam

customClass :: [MethodInfo] -> ClassInfo
customClass = Regular

implementation :: String -> [MethodInfo] -> ClassInfo
implementation = Implements

constructorInfo :: CodeChunk -> [Parameter] -> [Step] -> MethodInfo
constructorInfo = CI

methodInfo :: CodeChunk -> [Parameter] -> [Step] -> MethodInfo
methodInfo _ _ [] = error "methodInfo should be called with a non-empty list of Step"
methodInfo m ps ss = MI m ps (fromList ss)

appendCurrSol :: CodeChunk -> Step
appendCurrSol curr = statementStep (\cdchs es -> case (cdchs, es) of
    ([s], []) -> appendCurrSolFS curr s
    (_,_) -> error "Fill for appendCurrSol should provide one CodeChunk and no Exprs")
  
populateSolList :: CodeChunk -> CodeChunk -> CodeChunk -> [Step]
populateSolList arr el fld = [statementStep (\cdchs es -> case (cdchs, es) of
    ([s], []) -> FDecDef s (Matrix [[]])
    (_,_) -> error popErr),
  statementStep (\cdchs es -> case (cdchs, es) of
    ([s], []) -> FForEach el (sy arr) [appendCurrSolFS (ccObjVar el fld) s]
    (_,_) -> error popErr)]
  where popErr = "Fill for populateSolList should provide one CodeChunk and no Exprs"

assignArrayIndex :: Step
assignArrayIndex = statementStep (\cdchs es -> case (cdchs, es) of
  ([a],vs) -> FMulti $ zipWith (FAsgIndex a) [0..] vs
  (_,_) -> error "Fill for assignArrayIndex should provide one CodeChunk")

assignSolFromObj :: CodeChunk -> Step
assignSolFromObj o = statementStep (\cdchs es -> case (cdchs, es) of
  ([s],[]) -> FAsg s (sy $ ccObjVar o s)
  (_,_) -> error "Fill for assignSolFromObj should provide one CodeChunk and no Exprs")

initSolListFromArray :: CodeChunk -> Step
initSolListFromArray a = statementStep (\cdchs es -> case (cdchs, es) of
  ([s],[]) -> FAsg s (Matrix [[idx (sy a) (int 0)]])
  (_,_) -> error "Fill for initSolListFromArray should provide one CodeChunk and no Exprs")

initSolListWithVal :: Step
initSolListWithVal = statementStep (\cdchs es -> case (cdchs, es) of
  ([s],[v]) -> FDecDef s (Matrix [[v]])
  (_,_) -> error "Fill for initSolListWithVal should provide one CodeChunk and one Expr")

-- FunctionInterface for loop condition, CodeChunk for independent var,
-- FunctionInterface for solving, CodeChunk for soln array to populate with
solveAndPopulateWhile :: FunctionInterface -> CodeChunk -> FunctionInterface -> 
  CodeChunk -> Step
solveAndPopulateWhile lc iv slv popArr = loopStep [lc] (\case 
  [ub] -> sy iv $< ub
  _ -> error "Fill for solveAndPopulateWhile should provide one Expr") 
  [callStep slv, appendCurrSol popArr]

returnExprList :: Step
returnExprList = statementStep (\cdchs es -> case (cdchs, es) of
  ([], _) -> FRet $ Matrix [es]
  (_,_) -> error "Fill for returnExprList should provide no CodeChunks")

appendCurrSolFS :: CodeChunk -> CodeChunk -> FuncStmt
appendCurrSolFS cs s = FAppend (sy s) (idx (sy cs) (int 0))

fixedReturn :: Expr -> Step
fixedReturn = lockedStatement . FRet

statementStep :: ([CodeChunk] -> [Expr] -> FuncStmt) -> Step
statementStep = Statement

lockedStatement :: FuncStmt -> Step
lockedStatement s = Statement (\_ _ -> s)