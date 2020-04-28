{-# LANGUAGE PostfixOperators #-}

-- | The structure for a class of renderers is defined here.
module GOOL.Drasil.LanguageRenderer.LanguagePolymorphic (fileFromData,
  multiBody, block, multiBlock, bool, int, float, double, char, string, 
  fileType, listType, arrayType, listInnerType, obj, funcType, void, 
  notOp, notOp', negateOp, sqrtOp, sqrtOp', 
  absOp, absOp', expOp, expOp', sinOp, sinOp', cosOp, cosOp', tanOp, tanOp', 
  asinOp, asinOp', acosOp, acosOp', atanOp, atanOp', csc, sec, cot, 
  equalOp, notEqualOp, greaterOp, greaterEqualOp, lessOp, lessEqualOp, plusOp, 
  minusOp, multOp, divideOp, moduloOp, powerOp, andOp, orOp, addmathImport, bindingError, var, staticVar, 
  extVar, self, classVarCheckStatic, classVar, objVar, objVarSelf, 
  arrayElem, iterVar, litTrue, litFalse, litChar, litDouble, litFloat, litInt, 
  litString, litArray, litList, pi, valueOf, arg, argsList, inlineIf, call', 
  call, funcAppMixedArgs, namedArgError, selfFuncAppMixedArgs, 
  extFuncAppMixedArgs, libFuncAppMixedArgs, newObjMixedArgs, 
  extNewObjMixedArgs, libNewObjMixedArgs, lambda, notNull, objAccess, 
  objMethodCall, indexOf, func, get, set, listSize, 
  listAdd, listAppend, iterBegin, iterEnd, listAccess, listSet, getFunc, 
  setFunc, listSizeFunc, listAddFunc, listAppendFunc, iterBeginError, 
  iterEndError, listAccessFunc, listAccessFunc', listSetFunc, printSt, stmt, 
  loopStmt, emptyStmt, assign, multiAssignError, increment, 
  increment1, varDec, varDecDef, listDec, 
  listDecDef, listDecDef', arrayDec, arrayDecDef, objDecNew, 
  extObjDecNew, constDecDef, funcDecDef, print, 
  discardInput, discardFileInput, openFileR, openFileW, openFileA, closeFile, 
  discardFileLine, returnStmt, 
  multiReturnError, valStmt, comment, throw, ifCond, switch, for, 
  forRange, forEach, while, tryCatch, checkState, notifyObservers, construct, 
  param, method, getMethod, setMethod, constructor, destructorError, docMain, 
  function, mainFunction, docFuncRepr, docFunc, docInOutFunc, intFunc, stateVar,
  stateVarDef, constVar, buildClass, extraClass, implementingClass, docClass, 
  commentedClass, intClass, buildModule, buildModule', modFromData, fileDoc, 
  docMod
) where

import Utils.Drasil (indent)

import GOOL.Drasil.CodeType (CodeType(..), ClassName)
import GOOL.Drasil.ClassInterface (Label, Library, SFile, MSBody, MSBlock, 
  VSType, SVariable, SValue, VSFunction, MSStatement, MSParameter, SMethod, 
  CSStateVar, SClass, FSModule, NamedArgs, Initializers, MixedCall, 
  MixedCtorCall, FileSym(File), BodySym(Body), bodyStatements, oneLiner, 
  BlockSym(Block), PermanenceSym(..), TypeSym(Type, infile, outfile, iterator), 
  TypeElim(getType, getTypeString), VariableSym(Variable), 
  VariableElim(variableName, variableType), listOf, ValueSym(Value, valueType), 
  NumericExpression((#-), (#/), sin, cos, tan), Comparison(..), 
  funcApp, newObj, extNewObj, objMethodCallNoParams, ($.), at, StatementSym(multi), 
  AssignStatement((&+=), (&++)), (&=), 
  IOStatement(printStr, printStrLn, printFile, printFileStr, printFileStrLn),
  ControlStatement(break), ifNoElse, observerListName, ScopeSym(..), 
  ModuleSym(Module), convType)
import qualified GOOL.Drasil.ClassInterface as S (
  TypeSym(bool, int, float, double, char, string, listType, arrayType, 
    listInnerType, void), 
  VariableSym(var, self, objVar, objVarSelf),
  Literal(litTrue, litFalse, litInt, litString, litList), 
  VariableValue(valueOf),
  ValueExpression(funcAppMixedArgs, newObjMixedArgs, lambda), 
  FunctionSym(func, objAccess), 
  List(listSize, listAccess), StatementSym(valStmt),
  DeclStatement(varDec, varDecDef, constDecDef), 
  IOStatement(print),
  ControlStatement(returnStmt, for, switch), 
  ParameterSym(param), MethodSym(method, mainFunction), ClassSym(buildClass))
import GOOL.Drasil.RendererClasses (MSMthdType, RenderSym, 
  RenderFile(commentedMod),
  ImportSym(..),  
  RenderType(..),
  RenderVariable(varFromData),
  InternalVarElim(variableBind), 
  RenderValue(inputFunc, valFromData), ValueElim(valuePrec),
  InternalIterator(iterBeginFunc, iterEndFunc), RenderFunction(funcFromData), 
  FunctionElim(functionType), RenderStatement(stmtFromData), 
  StatementElim(statementTerm), RenderScope(..),
  MethodTypeSym(mType), RenderParam(paramFromData), 
  RenderMethod(intMethod, commentedFunc), 
  ParentSpec, 
  RenderClass(inherit, implements),
  RenderMod(updateModuleDoc), BlockCommentSym(..))
import qualified GOOL.Drasil.RendererClasses as S (RenderFile(fileFromData), 
  RenderBody(multiBody), RenderValue(call), 
  InternalGetSet(getFunc, setFunc),
  InternalListFunc(listSizeFunc, listAddFunc, listAppendFunc, listAccessFunc, 
    listSetFunc),
  RenderStatement(stmt, loopStmt), InternalIOStmt(..), 
  MethodTypeSym(construct), RenderMethod(intFunc), 
  RenderClass(intClass, commentedClass), RenderMod(modFromData))
import qualified GOOL.Drasil.RendererClasses as RC (ImportElim(..), 
  PermElim(..), BodyElim(..), BlockElim(..), InternalTypeElim(..), 
  InternalVarElim(variable), ValueElim(value), 
  FunctionElim(function), StatementElim(statement), ScopeElim(..), 
  MethodElim(..), StateVarElim(..), ClassElim(..), ModuleElim(..), 
  BlockCommentElim(..))
import GOOL.Drasil.AST (Binding(..), ScopeTag(..), Terminator(..), isSource)
import GOOL.Drasil.Helpers (angles, doubleQuotedText, vibcat, emptyIfEmpty, 
  toCode, toState, onCodeValue, onStateValue, on2StateValues, on3StateValues, 
  onStateList, on1StateValue1List, getInnerType, getNestDegree)
import GOOL.Drasil.LanguageRenderer (dot, forLabel, new, addExt, functionDox, 
  classDox, moduleDox, getterName, setterName, valueList, namedArgList, 
  intValue)
import qualified GOOL.Drasil.LanguageRenderer as R (file, module', block, 
  print, stateVar, stateVarList, switch, assign, addAssign, increment, 
  constDecDef, return', comment, getTerm, var, extVar, self, arg, objVar, func, 
  listAccessFunc, objAccess, commentedItem)
import GOOL.Drasil.LanguageRenderer.Constructors (mkStmt, mkStmtNoEnd, 
  mkStateVal, mkVal, mkStateVar, mkVar, mkStaticVar, VSOp, unOpPrec, 
  compEqualPrec, compPrec, addPrec, multPrec, powerPrec, andPrec, orPrec)
import GOOL.Drasil.State (FS, CS, MS, VS, lensFStoGS, lensFStoCS, lensFStoMS, 
  lensCStoMS, lensMStoVS, lensVStoMS, currMain, currFileType, modifyReturnFunc, 
  addFile, setMainMod, addLangImportVS, getLangImports, addLibImportVS, 
  getLibImports, getModuleImports, setModuleName, getModuleName, setClassName, 
  getClassName, addParameter, getParameters)

import Prelude hiding (break,print,last,mod,pi,sin,cos,tan,(<>))
import Data.List (sort)
import Data.Maybe (fromMaybe, maybeToList)
import Control.Applicative ((<|>))
import Control.Monad (join)
import Control.Monad.State (modify)
import Control.Lens ((^.), over)
import Control.Lens.Zoom (zoom)
import Text.PrettyPrint.HughesPJ (Doc, text, empty, render, (<>), (<+>), parens,
  brackets, braces, quotes, integer, vcat, semi, comma, equals, isEmpty)
import qualified Text.PrettyPrint.HughesPJ as D (char, double, float)

-- Bodies --

multiBody :: (RenderSym r, Monad r) => [MSBody r] -> MS (r Doc)
multiBody bs = onStateList (toCode . vibcat) $ map (onStateValue RC.body) bs

-- Blocks --

block :: (RenderSym r, Monad r) => [MSStatement r] -> MS (r Doc)
block sts = onStateList (toCode . R.block . map RC.statement) (map S.stmt sts)

multiBlock :: (RenderSym r, Monad r) => [MSBlock r] -> MS (r Doc)
multiBlock bs = onStateList (toCode . vibcat) $ map (onStateValue RC.block) bs

-- Types --

bool :: (RenderSym r) => VSType r
bool = toState $ typeFromData Boolean "Boolean" (text "Boolean")

int :: (RenderSym r) => VSType r
int = toState $ typeFromData Integer "int" (text "int")

float :: (RenderSym r) => VSType r
float = toState $ typeFromData Float "float" (text "float")

double :: (RenderSym r) => VSType r
double = toState $ typeFromData Double "double" (text "double")

char :: (RenderSym r) => VSType r
char = toState $ typeFromData Char "char" (text "char")

string :: (RenderSym r) => VSType r
string = toState $ typeFromData String "string" (text "string")

fileType :: (RenderSym r) => VSType r
fileType = toState $ typeFromData File "File" (text "File")

listType :: (RenderSym r) => String -> VSType r -> VSType r
listType lst = onStateValue (\t -> typeFromData (List (getType t)) (lst ++ "<" 
  ++ getTypeString t ++ ">") (text lst <> angles (RC.type' t)))

arrayType :: (RenderSym r) => VSType r -> VSType r
arrayType = onStateValue (\t -> typeFromData (Array (getType t)) 
  (getTypeString t ++ "[]") (RC.type' t <> brackets empty)) 

listInnerType :: (RenderSym r) => VSType r -> VSType r
listInnerType t = t >>= (convType . getInnerType . getType)

obj :: (RenderSym r) => ClassName -> VSType r
obj n = toState $ typeFromData (Object n) n (text n)

funcType :: (RenderSym r) => [VSType r] -> VSType r -> VSType r
funcType ps' = on2StateValues (\ps r -> typeFromData (Func (map getType ps) 
  (getType r)) "" empty) (sequence ps')

void :: (RenderSym r) => VSType r
void = toState $ typeFromData Void "void" (text "void")

-- Unary Operators --

notOp :: (Monad r) => VSOp r
notOp = unOpPrec "!"

notOp' :: (Monad r) => VSOp r
notOp' = unOpPrec "not"

negateOp :: (Monad r) => VSOp r
negateOp = unOpPrec "-"

sqrtOp :: (Monad r) => VSOp r
sqrtOp = unOpPrec "sqrt"

sqrtOp' :: (Monad r) => VSOp r
sqrtOp' = addmathImport $ unOpPrec "math.sqrt"

absOp :: (Monad r) => VSOp r
absOp = unOpPrec "fabs"

absOp' :: (Monad r) => VSOp r
absOp' = addmathImport $ unOpPrec "math.fabs"

expOp :: (Monad r) => VSOp r
expOp = unOpPrec "exp"

expOp' :: (Monad r) => VSOp r
expOp' = addmathImport $ unOpPrec "math.exp"

sinOp :: (Monad r) => VSOp r
sinOp = unOpPrec "sin"

sinOp' :: (Monad r) => VSOp r
sinOp' = addmathImport $ unOpPrec "math.sin"

cosOp :: (Monad r) => VSOp r
cosOp = unOpPrec "cos"

cosOp' :: (Monad r) => VSOp r
cosOp' = addmathImport $ unOpPrec "math.cos"

tanOp :: (Monad r) => VSOp r
tanOp = unOpPrec "tan"

tanOp' :: (Monad r) => VSOp r
tanOp' = addmathImport $ unOpPrec "math.tan"

asinOp :: (Monad r) => VSOp r
asinOp = unOpPrec "asin"

asinOp' :: (Monad r) => VSOp r
asinOp' = addmathImport $ unOpPrec "math.asin"

acosOp :: (Monad r) => VSOp r
acosOp = unOpPrec "acos"

acosOp' :: (Monad r) => VSOp r
acosOp' = addmathImport $ unOpPrec "math.acos"

atanOp :: (Monad r) => VSOp r
atanOp = unOpPrec "atan"

atanOp' :: (Monad r) => VSOp r
atanOp' = addmathImport $ unOpPrec "math.atan"

csc :: (RenderSym r) => SValue r -> SValue r
csc v = valOfOne (fmap valueType v) #/ sin v

sec :: (RenderSym r) => SValue r -> SValue r
sec v = valOfOne (fmap valueType v) #/ cos v

cot :: (RenderSym r) => SValue r -> SValue r
cot v = valOfOne (fmap valueType v) #/ tan v

valOfOne :: (RenderSym r) => VSType r -> SValue r
valOfOne t = t >>= (getVal . getType)
  where getVal Float = litFloat 1.0
        getVal _ = litDouble 1.0

-- Binary Operators --

equalOp :: (Monad r) => VSOp r
equalOp = compEqualPrec "=="

notEqualOp :: (Monad r) => VSOp r
notEqualOp = compEqualPrec "!="

greaterOp :: (Monad r) => VSOp r
greaterOp = compPrec ">"

greaterEqualOp :: (Monad r) => VSOp r
greaterEqualOp = compPrec ">="

lessOp :: (Monad r) => VSOp r
lessOp = compPrec "<"

lessEqualOp :: (Monad r) => VSOp r
lessEqualOp = compPrec "<="

plusOp :: (Monad r) => VSOp r
plusOp = addPrec "+"

minusOp :: (Monad r) => VSOp r
minusOp = addPrec "-"

multOp :: (Monad r) => VSOp r
multOp = multPrec "*"

divideOp :: (Monad r) => VSOp r
divideOp = multPrec "/"

moduloOp :: (Monad r) => VSOp r
moduloOp = multPrec "%"

powerOp :: (Monad r) => VSOp r
powerOp = powerPrec "pow"

andOp :: (Monad r) => VSOp r
andOp = andPrec "&&"

orOp :: (Monad r) => VSOp r
orOp = orPrec "||"

addmathImport :: VS a -> VS a
addmathImport = (>>) $ modify (addLangImportVS "math")

-- Binding --

bindingError :: String -> String
bindingError l = "Binding unimplemented in " ++ l

-- Variables --

var :: (RenderSym r) => Label -> VSType r -> SVariable r
var n t = mkStateVar n t (R.var n)

staticVar :: (RenderSym r) => Label -> VSType r -> SVariable r
staticVar n t = mkStaticVar n t (R.var n)

extVar :: (RenderSym r) => Label -> Label -> VSType r -> SVariable r
extVar l n t = mkStateVar (l ++ "." ++ n) t (R.extVar l n)

self :: (RenderSym r) => SVariable r
self = zoom lensVStoMS getClassName >>= (\l -> mkStateVar "this" (obj l) R.self)

-- | To be used in classVar implementations. Throws an error if the variable is 
-- not static since classVar is for accessing static variables from a class
classVarCheckStatic :: (RenderSym r) => r (Variable r) -> r (Variable r)
classVarCheckStatic v = classVarCS (variableBind v)
  where classVarCS Dynamic = error
          "classVar can only be used to access static variables"
        classVarCS Static = v

classVar :: (RenderSym r) => (Doc -> Doc -> Doc) -> VSType r -> SVariable r -> 
  SVariable r
classVar f = on2StateValues (\c v -> classVarCheckStatic $ varFromData 
  (variableBind v) (getTypeString c ++ "." ++ variableName v) 
  (variableType v) (f (RC.type' c) (RC.variable v)))

objVar :: (RenderSym r) => SVariable r -> SVariable r -> SVariable r
objVar = on2StateValues (\o v -> mkVar (variableName o ++ "." ++ variableName 
  v) (variableType v) (R.objVar (RC.variable o) (RC.variable v)))

objVarSelf :: (RenderSym r) => SVariable r -> SVariable r
objVarSelf = S.objVar S.self

arrayElem :: (RenderSym r) => SValue r -> SVariable r -> SVariable r
arrayElem i' v' = do
  i <- i'
  v <- v'
  let vName = variableName v ++ "[" ++ render (RC.value i) ++ "]"
      vType = listInnerType $ toState $ variableType v
      vRender = RC.variable v <> brackets (RC.value i)
  mkStateVar vName vType vRender

iterVar :: (RenderSym r) => Label -> VSType r -> SVariable r
iterVar n t = S.var n (iterator t)

-- Values --

litTrue :: (RenderSym r) => SValue r
litTrue = mkStateVal S.bool (text "true")

litFalse :: (RenderSym r) => SValue r
litFalse = mkStateVal S.bool (text "false")

litChar :: (RenderSym r) => Char -> SValue r
litChar c = mkStateVal S.char (quotes $ D.char c)

litDouble :: (RenderSym r) => Double -> SValue r
litDouble d = mkStateVal S.double (D.double d)

litFloat :: (RenderSym r) => Float -> SValue r
litFloat f = mkStateVal S.float (D.float f <> text "f")

litInt :: (RenderSym r) => Integer -> SValue r
litInt i = mkStateVal S.int (integer i)

litString :: (RenderSym r) => String -> SValue r
litString s = mkStateVal S.string (doubleQuotedText s)

litArray :: (RenderSym r) => VSType r -> [SValue r] -> SValue r
litArray t es = sequence es >>= (\elems -> mkStateVal (S.arrayType t) 
  (braces $ valueList elems))

litList :: (RenderSym r) => (VSType r -> VSType r) -> VSType r -> [SValue r] -> 
  SValue r
litList f t = on1StateValue1List (\lt es -> mkVal lt (new <+> RC.type' lt <+> 
  braces (valueList es))) (f t)

pi :: (RenderSym r) => SValue r
pi = mkStateVal S.double (text "Math.PI")

valueOf :: (RenderSym r) => SVariable r -> SValue r
valueOf = onStateValue (\v -> mkVal (variableType v) (RC.variable v))

arg :: (RenderSym r) => SValue r -> SValue r -> SValue r
arg = on3StateValues (\s n args -> mkVal s (R.arg n args)) S.string

argsList :: (RenderSym r) => String -> SValue r
argsList l = mkStateVal (S.arrayType S.string) (text l)

inlineIf :: (RenderSym r) => SValue r -> SValue r -> SValue r -> SValue r
inlineIf = on3StateValues (\c v1 v2 -> valFromData (prec c) (valueType v1) 
  (RC.value c <+> text "?" <+> RC.value v1 <+> text ":" <+> RC.value v2)) 
  where prec cd = valuePrec cd <|> Just 0

-- | First parameter is language name, rest similar to call from ClassInterface
call' :: (RenderSym r) => String -> Maybe Library -> Maybe Doc -> MixedCall r
call' l _ _ _ _ _ (_:_) = error $ namedArgError l
call' _ l o n t ps ns = call empty l o n t ps ns

-- | First parameter is separator between name and value for named arguments, 
-- rest similar to call from ClassInterface
call :: (RenderSym r) => Doc -> Maybe Library -> Maybe Doc -> MixedCall r
call sep lib o n t pas nas = do
  pargs <- sequence pas
  nms <- mapM fst nas
  nargs <- mapM snd nas
  let libDoc = maybe empty (text . (++ ".")) lib
      obDoc = fromMaybe empty o
  mkStateVal t $ obDoc <> libDoc <> text n <> parens (valueList pargs <+> 
    (if null pas || null nas then empty else comma) <+> namedArgList sep 
    (zip nms nargs))

funcAppMixedArgs :: (RenderSym r) => MixedCall r
funcAppMixedArgs = S.call Nothing Nothing

namedArgError :: String -> String
namedArgError l = "Named arguments not supported in " ++ l 

selfFuncAppMixedArgs :: (RenderSym r) => Doc -> SVariable r -> MixedCall r
selfFuncAppMixedArgs d slf n t vs ns = slf >>= (\s -> S.call Nothing 
  (Just $ RC.variable s <> d) n t vs ns)

extFuncAppMixedArgs :: (RenderSym r) => Library -> MixedCall r
extFuncAppMixedArgs l = S.call (Just l) Nothing

libFuncAppMixedArgs :: (RenderSym r) => Library -> MixedCall r
libFuncAppMixedArgs l n t vs ns = modify (addLibImportVS l) >> 
  S.funcAppMixedArgs n t vs ns

newObjMixedArgs :: (RenderSym r) => String -> MixedCtorCall r
newObjMixedArgs s tp vs ns = tp >>= 
  (\t -> S.call Nothing Nothing (s ++ getTypeString t) (return t) vs ns)

extNewObjMixedArgs :: (RenderSym r) => Library -> MixedCtorCall r
extNewObjMixedArgs l tp vs ns = tp >>= (\t -> S.call (Just l) Nothing 
  (getTypeString t) (return t) vs ns)

libNewObjMixedArgs :: (RenderSym r) => Library -> MixedCtorCall r
libNewObjMixedArgs l tp vs ns = modify (addLibImportVS l) >> 
  S.newObjMixedArgs tp vs ns

notNull :: (RenderSym r) => SValue r -> SValue r
notNull v = v ?!= S.valueOf (S.var "null" $ onStateValue valueType v)

lambda :: (RenderSym r) => ([r (Variable r)] -> r (Value r) -> Doc) -> 
  [SVariable r] -> SValue r -> SValue r
lambda f ps' ex' = sequence ps' >>= (\ps -> ex' >>= (\ex -> funcType (map 
  (toState . variableType) ps) (toState $ valueType ex) >>= (\ft -> 
  toState $ valFromData (Just 0) ft (f ps ex))))

objAccess :: (RenderSym r) => SValue r -> VSFunction r -> SValue r
objAccess = on2StateValues (\v f -> mkVal (functionType f) (R.objAccess 
  (RC.value v) (RC.function f)))

objMethodCall :: (RenderSym r) => Label -> VSType r -> SValue r -> [SValue r] 
  -> NamedArgs r -> SValue r
objMethodCall f t ob vs ns = ob >>= (\o -> S.call Nothing 
  (Just $ RC.value o <> dot) f t vs ns)

indexOf :: (RenderSym r) => Label -> SValue r -> SValue r -> SValue r
indexOf f l v = S.objAccess l (S.func f S.int [v])

-- Functions --

func :: (RenderSym r) => Label -> VSType r -> [SValue r] -> VSFunction r
func l t vs = funcApp l t vs >>= ((`funcFromData` t) . R.func . RC.value)

get :: (RenderSym r) => SValue r -> SVariable r -> SValue r
get v vToGet = v $. S.getFunc vToGet

set :: (RenderSym r) => SValue r -> SVariable r -> SValue r -> SValue r
set v vToSet toVal = v $. S.setFunc (onStateValue valueType v) vToSet toVal

listSize :: (RenderSym r) => SValue r -> SValue r
listSize v = v $. S.listSizeFunc

listAdd :: (RenderSym r) => SValue r -> SValue r -> SValue r -> SValue r
listAdd v i vToAdd = v $. S.listAddFunc v i vToAdd

listAppend :: (RenderSym r) => SValue r -> SValue r -> SValue r
listAppend v vToApp = v $. S.listAppendFunc vToApp

iterBegin :: (RenderSym r) => SValue r -> SValue r
iterBegin v = v $. iterBeginFunc (S.listInnerType $ onStateValue valueType v)

iterEnd :: (RenderSym r) => SValue r -> SValue r
iterEnd v = v $. iterEndFunc (S.listInnerType $ onStateValue valueType v)

listAccess :: (RenderSym r) => SValue r -> SValue r -> SValue r
listAccess v i = do
  v' <- v
  let checkType (List _) = S.listAccessFunc (S.listInnerType $ return $ 
        valueType v') i
      checkType (Array _) = i >>= (\ix -> funcFromData (brackets (RC.value ix)) 
        (S.listInnerType $ return $ valueType v'))
      checkType _ = error "listAccess called on non-list-type value"
  v $. checkType (getType (valueType v'))

listSet :: (RenderSym r) => SValue r -> SValue r -> SValue r -> SValue r
listSet v i toVal = v $. S.listSetFunc v i toVal

getFunc :: (RenderSym r) => SVariable r -> VSFunction r
getFunc v = v >>= (\vr -> S.func (getterName $ variableName vr) 
  (toState $ variableType vr) [])

setFunc :: (RenderSym r) => VSType r -> SVariable r -> SValue r -> VSFunction r
setFunc t v toVal = v >>= (\vr -> S.func (setterName $ variableName vr) t 
  [toVal])

listSizeFunc :: (RenderSym r) => VSFunction r
listSizeFunc = S.func "size" S.int []

listAddFunc :: (RenderSym r) => Label -> SValue r -> SValue r -> VSFunction r
listAddFunc f i v = S.func f (S.listType $ onStateValue valueType v) 
  [i, v]

listAppendFunc :: (RenderSym r) => Label -> SValue r -> VSFunction r
listAppendFunc f v = S.func f (S.listType $ onStateValue valueType v) [v]

iterBeginError :: String -> String
iterBeginError l = "Attempt to use iterBeginFunc in " ++ l ++ ", but " ++ l ++ 
  " has no iterators"

iterEndError :: String -> String
iterEndError l = "Attempt to use iterEndFunc in " ++ l ++ ", but " ++ l ++ 
  " has no iterators"

listAccessFunc :: (RenderSym r) => VSType r -> SValue r -> VSFunction r
listAccessFunc t v = intValue v >>= ((`funcFromData` t) . R.listAccessFunc)

listAccessFunc' :: (RenderSym r) => Label -> VSType r -> SValue r -> 
  VSFunction r
listAccessFunc' f t i = S.func f t [intValue i]

listSetFunc :: (RenderSym r) => (Doc -> Doc -> Doc) -> SValue r -> SValue r -> 
  SValue r -> VSFunction r
listSetFunc f v idx setVal = join $ on2StateValues (\i toVal -> funcFromData 
  (f (RC.value i) (RC.value toVal)) (onStateValue valueType v)) (intValue idx) 
  setVal

-- Statements --

printSt :: (RenderSym r) => SValue r -> SValue r -> MSStatement r
printSt p v = zoom lensMStoVS $ on2StateValues (\p' -> mkStmt . R.print p') p v

stmt :: (RenderSym r) => MSStatement r -> MSStatement r
stmt = onStateValue (\s -> mkStmtNoEnd (RC.statement s <> R.getTerm 
  (statementTerm s)))
  
loopStmt :: (RenderSym r) => MSStatement r -> MSStatement r
loopStmt = S.stmt . setEmpty

emptyStmt :: (RenderSym r) => MSStatement r
emptyStmt = toState $ mkStmtNoEnd empty

assign :: (RenderSym r) => Terminator -> SVariable r -> SValue r -> 
  MSStatement r
assign t vr vl = zoom lensMStoVS $ on2StateValues (\vr' vl' -> stmtFromData 
  (R.assign vr' vl') t) vr vl

multiAssignError :: String -> String
multiAssignError l = "No multiple assignment statements in " ++ l

increment :: (RenderSym r) => SVariable r -> SValue r -> MSStatement r
increment vr vl = zoom lensMStoVS $ on2StateValues (\vr' -> mkStmt . 
  R.addAssign vr') vr vl

increment1 :: (RenderSym r) => SVariable r -> MSStatement r
increment1 vr = zoom lensMStoVS $ onStateValue (mkStmt . R.increment) vr

varDec :: (RenderSym r) => r (Permanence r) -> r (Permanence r) -> SVariable r 
  -> MSStatement r
varDec s d v' = onStateValue (\v -> mkStmt (RC.perm (bind $ variableBind v) 
  <+> RC.type' (variableType v) <+> RC.variable v)) (zoom lensMStoVS v')
  where bind Static = s
        bind Dynamic = d

varDecDef :: (RenderSym r) => SVariable r -> SValue r -> MSStatement r
varDecDef vr vl' = on2StateValues (\vd vl -> mkStmt (RC.statement vd <+> equals 
  <+> RC.value vl)) (S.varDec vr) (zoom lensMStoVS vl')

listDec :: (RenderSym r) => (r (Value r) -> Doc) -> SValue r -> SVariable r -> 
  MSStatement r
listDec f vl v = on2StateValues (\sz vd -> mkStmt (RC.statement vd <> f 
  sz)) (zoom lensMStoVS vl) (S.varDec v)

listDecDef :: (RenderSym r) => ([r (Value r)] -> Doc) -> SVariable r -> 
  [SValue r] -> MSStatement r
listDecDef f v vls = on1StateValue1List (\vd vs -> mkStmt (RC.statement vd <> 
  f vs)) (S.varDec v) (map (zoom lensMStoVS) vls)

listDecDef' :: (RenderSym r) => SVariable r -> [SValue r] -> MSStatement r
listDecDef' v vals = zoom lensMStoVS v >>= (\vr -> S.varDecDef (return vr) 
  (S.litList (listInnerType $ return $ variableType vr) vals))

arrayDec :: (RenderSym r) => SValue r -> SVariable r -> MSStatement r
arrayDec n vr = zoom lensMStoVS $ do
  sz <- n 
  v <- vr 
  let tp = variableType v
  innerTp <- listInnerType $ toState tp
  toState $ mkStmt $ RC.type' tp <+> RC.variable v <+> equals <+> new <+> 
    RC.type' innerTp <> brackets (RC.value sz)

arrayDecDef :: (RenderSym r) => SVariable r -> [SValue r] -> MSStatement r
arrayDecDef v vals = on2StateValues (\vd vs -> mkStmt (RC.statement vd <+> 
  equals <+> braces (valueList vs))) (S.varDec v) (mapM (zoom lensMStoVS) vals)

objDecNew :: (RenderSym r) => SVariable r -> [SValue r] -> MSStatement r
objDecNew v vs = S.varDecDef v (newObj (onStateValue variableType v) vs)

extObjDecNew :: (RenderSym r) => Library -> SVariable r -> [SValue r] -> 
  MSStatement r
extObjDecNew l v vs = S.varDecDef v (extNewObj l (onStateValue variableType v)
  vs)

constDecDef :: (RenderSym r) => SVariable r -> SValue r -> MSStatement r
constDecDef vr vl = zoom lensMStoVS $ on2StateValues (\v -> mkStmt . 
  R.constDecDef v) vr vl

funcDecDef :: (RenderSym r) => SVariable r -> [SVariable r] -> SValue r -> 
  MSStatement r
funcDecDef v ps r = S.varDecDef v (S.lambda ps r)

printList :: (RenderSym r) => Integer -> SValue r -> (SValue r -> MSStatement r)
  -> (String -> MSStatement r) -> (String -> MSStatement r) -> MSStatement r
printList n v prFn prStrFn prLnFn = multi [prStrFn "[", 
  S.for (S.varDecDef i (S.litInt 0)) 
    (S.valueOf i ?< (S.listSize v #- S.litInt 1)) (i &++) 
    (bodyStatements [prFn (S.listAccess v (S.valueOf i)), prStrFn ", "]), 
  ifNoElse [(S.listSize v ?> S.litInt 0, oneLiner $
    prFn (S.listAccess v (S.listSize v #- S.litInt 1)))], 
  prLnFn "]"]
  where l_i = "list_i" ++ show n
        i = S.var l_i S.int

printObj :: ClassName -> (String -> MSStatement r) -> MSStatement r
printObj n prLnFn = prLnFn $ "Instance of " ++ n ++ " object"

print :: (RenderSym r) => Bool -> Maybe (SValue r) -> SValue r -> SValue r -> 
  MSStatement r
print newLn f printFn v = zoom lensMStoVS v >>= print' . getType . valueType
  where print' (List t) = printList (getNestDegree 1 t) v prFn prStrFn 
          prLnFn
        print' (Object n) = printObj n prLnFn
        print' _ = S.printSt newLn f printFn v
        prFn = maybe S.print printFile f
        prStrFn = maybe printStr printFileStr f
        prLnFn = if newLn then maybe printStrLn printFileStrLn f else maybe 
          printStr printFileStr f 

discardInput :: (RenderSym r) => (r (Value r) -> Doc) -> MSStatement r
discardInput f = zoom lensMStoVS $ onStateValue (mkStmt . f) inputFunc

discardFileInput :: (RenderSym r) => (r (Value r) -> Doc) -> SValue r -> 
  MSStatement r
discardFileInput f v = zoom lensMStoVS $ onStateValue (mkStmt . f) v

openFileR :: (RenderSym r) => (SValue r -> VSType r -> SValue r) -> SVariable r 
  -> SValue r -> MSStatement r
openFileR f vr vl = vr &= f vl infile

openFileW :: (RenderSym r) => (SValue r -> VSType r -> SValue r -> SValue r) -> 
  SVariable r -> SValue r -> MSStatement r
openFileW f vr vl = vr &= f vl outfile S.litFalse

openFileA :: (RenderSym r) => (SValue r -> VSType r -> SValue r -> SValue r) -> 
  SVariable r -> SValue r -> MSStatement r
openFileA f vr vl = vr &= f vl outfile S.litTrue

closeFile :: (RenderSym r) => Label -> SValue r -> MSStatement r
closeFile n f = S.valStmt $ objMethodCallNoParams S.void f n

discardFileLine :: (RenderSym r) => Label -> SValue r -> MSStatement r
discardFileLine n f = S.valStmt $ objMethodCallNoParams S.string f n 

returnStmt :: (RenderSym r) => Terminator -> SValue r -> MSStatement r
returnStmt t v' = zoom lensMStoVS $ onStateValue (\v -> stmtFromData 
  (R.return' [v]) t) v'

multiReturnError :: String -> String
multiReturnError l = "Cannot return multiple values in " ++ l

valStmt :: (RenderSym r) => Terminator -> SValue r -> MSStatement r
valStmt t v' = zoom lensMStoVS $ onStateValue (\v -> stmtFromData (RC.value v)
  t) v'

comment :: (RenderSym r) => Doc -> Label -> MSStatement r
comment cs c = toState $ mkStmtNoEnd (R.comment c cs)

throw :: (RenderSym r) => (r (Value r) -> Doc) -> Terminator -> Label -> 
  MSStatement r
throw f t = onStateValue (\msg -> stmtFromData (f msg) t) . zoom lensMStoVS . 
  S.litString

-- ControlStatements --

ifCond :: (RenderSym r) => Doc -> Doc -> Doc -> [(SValue r, MSBody r)] -> 
  MSBody r -> MSStatement r
ifCond _ _ _ [] _ = error "if condition created with no cases"
ifCond ifStart elif bEnd (c:cs) eBody =
    let ifSect (v, b) = on2StateValues (\val bd -> vcat [
          text "if" <+> parens (RC.value val) <+> ifStart,
          indent $ RC.body bd,
          bEnd]) (zoom lensMStoVS v) b
        elseIfSect (v, b) = on2StateValues (\val bd -> vcat [
          elif <+> parens (RC.value val) <+> ifStart,
          indent $ RC.body bd,
          bEnd]) (zoom lensMStoVS v) b
        elseSect = onStateValue (\bd -> emptyIfEmpty (RC.body bd) $ vcat [
          text "else" <+> ifStart,
          indent $ RC.body bd,
          bEnd]) eBody
    in onStateList (mkStmtNoEnd . vcat)
      (ifSect c : map elseIfSect cs ++ [elseSect])

switch :: (RenderSym r) => SValue r -> [(SValue r, MSBody r)] -> MSBody r -> 
  MSStatement r
switch v cs bod = do
  brk <- S.stmt break
  val <- zoom lensMStoVS v
  vals <- mapM (zoom lensMStoVS . fst) cs
  bods <- mapM snd cs
  dflt <- bod
  toState $ mkStmt $ R.switch brk val dflt (zip vals bods)

for :: (RenderSym r) => Doc -> Doc -> MSStatement r -> SValue r -> 
  MSStatement r -> MSBody r -> MSStatement r
for bStart bEnd sInit vGuard sUpdate b = do
  initl <- S.loopStmt sInit
  guard <- zoom lensMStoVS vGuard
  upd <- S.loopStmt sUpdate
  bod <- b
  toState $ mkStmtNoEnd $ vcat [
    forLabel <+> parens (RC.statement initl <> semi <+> RC.value guard <> 
      semi <+> RC.statement upd) <+> bStart,
    indent $ RC.body bod,
    bEnd]

forRange :: (RenderSym r) => SVariable r -> SValue r -> SValue r -> SValue r -> 
  MSBody r -> MSStatement r
forRange i initv finalv stepv = S.for (S.varDecDef i initv) (S.valueOf i ?< 
  finalv) (i &+= stepv)

forEach :: (RenderSym r) => Doc -> Doc -> Doc -> Doc -> SVariable r -> SValue r 
  -> MSBody r -> MSStatement r
forEach bStart bEnd forEachLabel inLbl e' v' b' = do
  e <- zoom lensMStoVS e'
  v <- zoom lensMStoVS v'
  b <- b'
  toState $ mkStmtNoEnd $ vcat [
    forEachLabel <+> parens (RC.type' (variableType e) <+> RC.variable e <+> 
      inLbl <+> RC.value v) <+> bStart,
    indent $ RC.body b,
    bEnd] 

while :: (RenderSym r) => Doc -> Doc -> SValue r -> MSBody r -> MSStatement r
while bStart bEnd v' = on2StateValues (\v b -> mkStmtNoEnd (vcat [
  text "while" <+> parens (RC.value v) <+> bStart,
  indent $ RC.body b,
  bEnd])) (zoom lensMStoVS v')

tryCatch :: (RenderSym r) => (r (Body r) -> r (Body r) -> Doc) -> MSBody r -> 
  MSBody r -> MSStatement r
tryCatch f = on2StateValues (\tb -> mkStmtNoEnd . f tb)

checkState :: (RenderSym r) => Label -> [(SValue r, MSBody r)] -> MSBody r -> 
  MSStatement r
checkState l = S.switch (S.valueOf $ S.var l S.string)

notifyObservers :: (RenderSym r) => VSFunction r -> VSType r -> MSStatement r
notifyObservers f t = S.for initv (v_index ?< S.listSize obsList) 
  (var_index &++) notify
  where obsList = S.valueOf $ observerListName `listOf` t 
        var_index = S.var "observerIndex" S.int
        v_index = S.valueOf var_index
        initv = S.varDecDef var_index $ S.litInt 0
        notify = oneLiner $ S.valStmt $ at obsList v_index $. f

-- Methods --

construct :: (RenderSym r) => Label -> MS (r (Type r))
construct n = toState $ typeFromData (Object n) n empty

param :: (RenderSym r) => (r (Variable r) -> Doc) -> SVariable r -> 
  MSParameter r
param f v' = modifyReturnFunc (\v s -> addParameter (variableName v) s) 
  (\v -> paramFromData v (f v)) (zoom lensMStoVS v')

method :: (RenderSym r) => Label -> r (Scope r) -> r (Permanence r) -> VSType r 
  -> [MSParameter r] -> MSBody r -> SMethod r
method n s p t = intMethod False n s p (mType t)

getMethod :: (RenderSym r) => SVariable r -> SMethod r
getMethod v = zoom lensMStoVS v >>= (\vr -> S.method (getterName $ variableName 
  vr) public dynamic (toState $ variableType vr) [] getBody)
  where getBody = oneLiner $ S.returnStmt (S.valueOf $ S.objVarSelf v)

setMethod :: (RenderSym r) => SVariable r -> SMethod r
setMethod v = zoom lensMStoVS v >>= (\vr -> S.method (setterName $ variableName 
  vr) public dynamic S.void [S.param v] setBody)
  where setBody = oneLiner $ S.objVarSelf v &= S.valueOf v

constructor :: (RenderSym r) => Label -> [MSParameter r] -> Initializers r -> 
  MSBody r -> SMethod r
constructor fName ps is b = getClassName >>= (\c -> intMethod False fName 
  public dynamic (S.construct c) ps (S.multiBody [ib, b]))
  where ib = bodyStatements (zipWith (\vr vl -> objVarSelf vr &= vl) 
          (map fst is) (map snd is))
 
destructorError :: String -> String
destructorError l = "Destructors not allowed in " ++ l

docMain :: (RenderSym r) => MSBody r -> SMethod r
docMain b = commentedFunc (docComment $ toState $ functionDox 
  "Controls the flow of the program" 
  [("args", "List of command-line arguments")] []) (S.mainFunction b)

function :: (RenderSym r) => Label -> r (Scope r) -> r (Permanence r) -> 
  VSType r -> [MSParameter r] -> MSBody r -> SMethod r
function n s p t = S.intFunc False n s p (mType t)

mainFunction :: (RenderSym r) => VSType r -> Label -> MSBody r -> SMethod r
mainFunction s n = S.intFunc True n public static (mType S.void)
  [S.param (S.var "args" (onStateValue (\argT -> typeFromData (List String) 
  (render (RC.type' argT) ++ "[]") (RC.type' argT <> text "[]")) s))]
  
docFuncRepr :: (RenderSym r) => String -> [String] -> [String] -> SMethod r -> 
  SMethod r
docFuncRepr desc pComms rComms = commentedFunc (docComment $ onStateValue 
  (\ps -> functionDox desc (zip ps pComms) rComms) getParameters)

docFunc :: (RenderSym r) => String -> [String] -> Maybe String -> SMethod r -> 
  SMethod r
docFunc desc pComms rComm = docFuncRepr desc pComms (maybeToList rComm)

docInOutFunc :: (RenderSym r) => (r (Scope r) -> r (Permanence r) -> 
    [SVariable r] -> [SVariable r] -> [SVariable r] -> MSBody r -> SMethod r)
  -> r (Scope r) -> r (Permanence r) -> String -> [(String, SVariable r)] -> 
  [(String, SVariable r)] -> [(String, SVariable r)] -> MSBody r -> SMethod r
docInOutFunc f s p desc is [o] [] b = docFuncRepr desc (map fst is) [fst o] 
  (f s p (map snd is) [snd o] [] b)
docInOutFunc f s p desc is [] [both] b = docFuncRepr desc (map fst $ both : is) 
  [fst both] (f s p (map snd is) [] [snd both] b)
docInOutFunc f s p desc is os bs b = docFuncRepr desc (map fst $ bs ++ is ++ os)
  [] (f s p (map snd is) (map snd os) (map snd bs) b)

intFunc :: (RenderSym r) => Bool -> Label -> r (Scope r) -> r (Permanence r) -> 
  MSMthdType r -> [MSParameter r] -> MSBody r -> SMethod r
intFunc = intMethod

-- State Variables --

stateVar :: (RenderSym r, Monad r) => r (Scope r) -> r (Permanence r) -> 
  SVariable r -> CS (r Doc)
stateVar s p v = zoom lensCStoMS $ onStateValue (toCode . R.stateVar 
  (RC.scope s) (RC.perm p) . RC.statement) (S.stmt $ S.varDec v)

stateVarDef :: (RenderSym r, Monad r) => r (Scope r) -> r (Permanence r) -> 
  SVariable r -> SValue r -> CS (r Doc)
stateVarDef s p vr vl = zoom lensCStoMS $ onStateValue (toCode . R.stateVar 
  (RC.scope s) (RC.perm p) . RC.statement) (S.stmt $ S.varDecDef vr vl)

constVar :: (RenderSym r, Monad r) => Doc -> r (Scope r) -> SVariable r -> 
  SValue r -> CS (r Doc)
constVar p s vr vl = zoom lensCStoMS $ onStateValue (toCode . R.stateVar 
  (RC.scope s) p . RC.statement) (S.stmt $ S.constDecDef vr vl)

-- Classes --

buildClass :: (RenderSym r) => Label -> Maybe Label -> [CSStateVar r] -> 
  [SMethod r] -> SClass r
buildClass n = S.intClass n public . inherit

extraClass :: (RenderSym r) => Label -> Maybe Label -> [CSStateVar r] -> 
  [SMethod r] -> SClass r
extraClass n = S.intClass n (scopeFromData Priv empty) . inherit

implementingClass :: (RenderSym r) => Label -> [Label] -> [CSStateVar r] -> 
  [SMethod r] -> SClass r
implementingClass n is = S.intClass n public (implements is)

docClass :: (RenderSym r) => String -> SClass r -> SClass r
docClass d = S.commentedClass (docComment $ toState $ classDox d)

commentedClass :: (RenderSym r, Monad r) => CS (r (BlockComment r)) -> SClass r 
  -> CS (r Doc)
commentedClass = on2StateValues (\cmt cs -> toCode $ R.commentedItem 
  (RC.blockComment' cmt) (RC.class' cs))

intClass :: (RenderSym r, Monad r) => (Label -> Doc -> Doc -> Doc -> Doc -> 
  Doc) -> Label -> r (Scope r) -> r ParentSpec -> [CSStateVar r] -> [SMethod r] 
  -> CS (r Doc)
intClass f n s i svrs mths = do
  modify (setClassName n) 
  svs <- onStateList (R.stateVarList . map RC.stateVar) svrs
  ms <- onStateList (vibcat . map RC.method) (map (zoom lensCStoMS) mths)
  toState $ onCodeValue (\p -> f n p (RC.scope s) svs ms) i 

-- Modules --

buildModule :: (RenderSym r) => Label -> FS Doc -> FS Doc -> [SMethod r] -> 
  [SClass r] -> FSModule r
buildModule n imps bot fs cs = S.modFromData n (do
  cls <- mapM (zoom lensFStoCS) cs
  fns <- mapM (zoom lensFStoMS) fs
  is <- imps
  bt <- bot
  toState $ R.module' is (vibcat (map RC.class' cls)) 
    (vibcat (map RC.method fns ++ [bt])))

buildModule' :: (RenderSym r) => Label -> (String -> r (Import r)) -> [Label] 
  -> [SMethod r] -> [SClass r] -> FSModule r
buildModule' n inc is ms cs = S.modFromData n (do
  cls <- mapM (zoom lensFStoCS) 
          (if null ms then cs else S.buildClass n Nothing [] ms : cs) 
  lis <- getLangImports
  libis <- getLibImports
  mis <- getModuleImports
  toState $ vibcat [
    vcat (map (RC.import' . inc) (lis ++ sort (is ++ libis) ++ mis)),
    vibcat (map RC.class' cls)])

modFromData :: Label -> (Doc -> r (Module r)) -> FS Doc -> FSModule r
modFromData n f d = modify (setModuleName n) >> onStateValue f d

-- Files --

fileDoc :: (RenderSym r) => String -> (r (Module r) -> r (Block r)) -> 
  r (Block r) -> FSModule r -> SFile r
fileDoc ext topb botb = S.fileFromData (onStateValue (addExt ext) 
  getModuleName) . onStateValue (\m -> updateModuleDoc (\d -> emptyIfEmpty d 
  (R.file (RC.block $ topb m) d (RC.block botb))) m)

docMod :: (RenderSym r) => String -> String -> [String] -> String -> SFile r -> 
  SFile r
docMod e d a dt = commentedMod (docComment $ moduleDox d a dt . addExt e <$> 
  getModuleName)

fileFromData :: (RenderSym r) => (FilePath -> r (Module r) -> r (File r)) 
  -> FS FilePath -> FSModule r -> SFile r
fileFromData f fp m = do
  mdl <- m
  fpath <- fp
  modify (\s -> if isEmpty (RC.module' mdl) 
    then s
    else over lensFStoGS (addFile (s ^. currFileType) fpath) $ 
      if s ^. currMain && isSource (s ^. currFileType) 
        then over lensFStoGS (setMainMod fpath) s
        else s)
  toState $ f fpath mdl


-- Helper functions

setEmpty :: (RenderSym r) => MSStatement r -> MSStatement r
setEmpty = onStateValue (mkStmtNoEnd . RC.statement)