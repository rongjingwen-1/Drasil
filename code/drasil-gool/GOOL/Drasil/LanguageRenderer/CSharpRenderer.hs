{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE PostfixOperators #-}

-- | The logic to render C# code is contained in this module
module GOOL.Drasil.LanguageRenderer.CSharpRenderer (
  -- * C# Code Configuration -- defines syntax of all C# code
  CSharpCode(..)
) where

import Utils.Drasil (indent)

import GOOL.Drasil.CodeType (CodeType(..))
import GOOL.Drasil.ClassInterface (Label, MSBody, VSType, SVariable, SValue, 
  MSStatement, MSParameter, SMethod, OOProg, ProgramSym(..), FileSym(..), 
  PermanenceSym(..), BodySym(..), oneLiner, BlockSym(..), TypeSym(..), 
  TypeElim(..), ControlBlock(..), VariableSym(..), VariableElim(..), 
  ValueSym(..), Literal(..), MathConstant(..), VariableValue(..),
  CommandLineArgs(..), NumericExpression(..), BooleanExpression(..), 
  Comparison(..), ValueExpression(..), funcApp, selfFuncApp, extFuncApp, 
  newObj, InternalValueExp(..), objMethodCall, objMethodCallNoParams, 
  FunctionSym(..), ($.), GetSet(..), List(..), InternalList(..), Iterator(..), 
  StatementSym(..), AssignStatement(..), (&=), DeclStatement(..), 
  objDecNewNoParams, IOStatement(..), StringStatement(..), FuncAppStatement(..),
  CommentStatement(..), ControlStatement(..), StatePattern(..), 
  ObserverPattern(..), StrategyPattern(..), ScopeSym(..), ParameterSym(..),
  MethodSym(..), StateVarSym(..), ClassSym(..), ModuleSym(..), ODEInfo(..), 
  ODEOptions(..), ODEMethod(..))
import GOOL.Drasil.RendererClasses (RenderSym, RenderFile(..), ImportSym(..), 
  ImportElim, PermElim(binding), RenderBody(..), BodyElim, RenderBlock(..), 
  BlockElim, RenderType(..), InternalTypeElim, UnaryOpSym(..), BinaryOpSym(..), 
  OpElim(uOpPrec, bOpPrec), RenderVariable(..), InternalVarElim(variableBind), 
  RenderValue(..), ValueElim(valuePrec), InternalGetSet(..), 
  InternalListFunc(..), InternalIterator(..), RenderFunction(..), 
  FunctionElim(functionType), InternalAssignStmt(..), InternalIOStmt(..), 
  InternalControlStmt(..), RenderStatement(..), StatementElim(statementTerm), 
  RenderScope(..), ScopeElim, MethodTypeSym(..), RenderParam(..), 
  ParamElim(parameterName, parameterType), RenderMethod(..), MethodElim, 
  StateVarElim, RenderClass(..), ClassElim, RenderMod(..), ModuleElim, 
  BlockCommentSym(..), BlockCommentElim)
import qualified GOOL.Drasil.RendererClasses as RC (import', perm, body, block,
  type', uOp, bOp, variable, value, function, statement, scope, parameter,
  method, stateVar, class', module', blockComment')
import GOOL.Drasil.LanguageRenderer (new, dot, blockCmtStart, blockCmtEnd, 
  docCmtStart, bodyStart, bodyEnd, endStatement, commentStart, elseIfLabel, 
  inLabel, valueList, variableList, appendToBody, surroundBody)
import qualified GOOL.Drasil.LanguageRenderer as R (class', multiStmt, body, 
  printFile, param, method, listDec, classVar, objVar, func, cast, listSetFunc, 
  castObj, static, dynamic, break, continue, private, public, blockCmt, docCmt, 
  addComments, commentedMod, commentedItem)
import GOOL.Drasil.LanguageRenderer.Constructors (mkStmt, mkStmtNoEnd, 
  mkStateVal, mkVal, mkVar, unOpPrec, powerPrec, unExpr, unExpr', unExprNumDbl, 
  typeUnExpr, binExpr, binExprNumDbl', typeBinExpr)
import qualified GOOL.Drasil.LanguageRenderer.LanguagePolymorphic as G (
  multiBody, block, multiBlock, int, listInnerType, obj, funcType, csc, sec, 
  cot, negateOp, equalOp, notEqualOp, greaterOp, greaterEqualOp, lessOp, 
  lessEqualOp, plusOp, minusOp, multOp, divideOp, moduloOp, var, staticVar, 
  arrayElem, litChar, litDouble, litInt, litString, valueOf, arg, argsList, 
  objAccess, objMethodCall, call, funcAppMixedArgs, selfFuncAppMixedArgs, 
  newObjMixedArgs, lambda, func, get, set, listAdd, listAppend, iterBegin, 
  iterEnd, listAccess, listSet, getFunc, setFunc, listAppendFunc, stmt, 
  loopStmt, emptyStmt, assign, increment, objDecNew, print, closeFile,
  returnStmt, valStmt, comment, throw, ifCond, tryCatch, construct, param, 
  method, getMethod, setMethod, constructor, function, docFunc, buildClass, 
  implementingClass, docClass, commentedClass, modFromData, fileDoc, docMod, 
  fileFromData)
import qualified GOOL.Drasil.LanguageRenderer.CommonPseudoOO as CP (
  bindingError, extVar, classVar, objVarSelf, iterVar, extFuncAppMixedArgs, 
  indexOf, listAddFunc, iterBeginError, iterEndError, listDecDef, 
  discardFileLine, destructorError, stateVarDef, constVar, 
  intClass, listSetFunc, listAccessFunc, bool, arrayType, pi, notNull, printSt, 
  arrayDec, arrayDecDef, openFileR, openFileW, openFileA, forEach, docMain, 
  mainFunction, stateVar, buildModule', string, constDecDef, docInOutFunc)
import qualified GOOL.Drasil.LanguageRenderer.CLike as C (float, double, char, 
  listType, void, notOp, andOp, orOp, self, litTrue, litFalse, litFloat, 
  inlineIf, libFuncAppMixedArgs, libNewObjMixedArgs, listSize, increment1, 
  varDec, varDecDef, listDec, extObjDecNew, discardInput, switch, for,
  while, intFunc, multiAssignError, multiReturnError)
import qualified GOOL.Drasil.LanguageRenderer.Macros as M (ifExists, decrement, 
  decrement1, runStrategy, listSlice, stringListVals, stringListLists,
  forRange, notifyObservers, checkState)
import GOOL.Drasil.AST (Terminator(..), FileType(..), FileData(..), fileD, 
  FuncData(..), fd, ModData(..), md, updateMod, MethodData(..), mthd, 
  updateMthd, OpData(..), ParamData(..), pd, updateParam, ProgData(..), progD, 
  TypeData(..), td, ValData(..), vd, updateValDoc, Binding(..), VarData(..), 
  vard)
import GOOL.Drasil.Helpers (toCode, toState, onCodeValue, onStateValue, 
  on2CodeValues, on2StateValues, on3CodeValues, on3StateValues, onCodeList, 
  onStateList, on1StateValue1List)
import GOOL.Drasil.State (VS, lensGStoFS, lensMStoVS, modifyReturn, revFiles,
  addLangImport, addLangImportVS, addLibImport, setFileType, getClassName, 
  setCurrMain, setODEDepVars, getODEDepVars)

import Prelude hiding (break,print,(<>),sin,cos,tan,floor)
import Control.Lens.Zoom (zoom)
import Control.Applicative (Applicative)
import Control.Monad (join)
import Control.Monad.State (modify)
import Data.List (elemIndex, intercalate)
import Text.PrettyPrint.HughesPJ (Doc, text, (<>), (<+>), ($$), parens, empty,
  vcat, lbrace, rbrace, braces, colon, space)

csExt :: String
csExt = "cs"

newtype CSharpCode a = CSC {unCSC :: a} deriving Eq

instance Functor CSharpCode where
  fmap f (CSC x) = CSC (f x)

instance Applicative CSharpCode where
  pure = CSC
  (CSC f) <*> (CSC x) = CSC (f x)

instance Monad CSharpCode where
  return = CSC
  CSC x >>= f = f x

instance OOProg CSharpCode where

instance ProgramSym CSharpCode where
  type Program CSharpCode = ProgData
  prog n files = do
    fs <- mapM (zoom lensGStoFS) files
    modify revFiles
    return $ onCodeList (progD n) fs

instance RenderSym CSharpCode

instance FileSym CSharpCode where
  type File CSharpCode = FileData
  fileDoc m = do
    modify (setFileType Combined)
    G.fileDoc csExt top bottom m

  docMod = G.docMod csExt

instance RenderFile CSharpCode where
  top _ = toCode empty
  bottom = toCode empty

  commentedMod = on2StateValues (on2CodeValues R.commentedMod)

  fileFromData = G.fileFromData (onCodeValue . fileD)

instance ImportSym CSharpCode where
  type Import CSharpCode = Doc
  langImport = toCode . csImport
  modImport = langImport

instance ImportElim CSharpCode where
  import' = unCSC

instance PermanenceSym CSharpCode where
  type Permanence CSharpCode = Doc
  static = toCode R.static
  dynamic = toCode R.dynamic

instance PermElim CSharpCode where
  perm = unCSC
  binding = error $ CP.bindingError csName

instance BodySym CSharpCode where
  type Body CSharpCode = Doc
  body = onStateList (onCodeList R.body)

  addComments s = onStateValue (onCodeValue (R.addComments s commentStart))

instance RenderBody CSharpCode where
  multiBody = G.multiBody 

instance BodyElim CSharpCode where
  body = unCSC

instance BlockSym CSharpCode where
  type Block CSharpCode = Doc
  block = G.block

instance RenderBlock CSharpCode where
  multiBlock = G.multiBlock

instance BlockElim CSharpCode where
  block = unCSC

instance TypeSym CSharpCode where
  type Type CSharpCode = TypeData
  bool = addSystemImport CP.bool
  int = G.int
  float = C.float
  double = C.double
  char = C.char
  string = CP.string
  infile = csInfileType
  outfile = csOutfileType
  listType t = do
    modify (addLangImportVS "System.Collections.Generic") 
    C.listType "List" t
  arrayType = CP.arrayType
  listInnerType = G.listInnerType
  obj = G.obj
  funcType = G.funcType
  iterator t = t
  void = C.void

instance TypeElim CSharpCode where
  getType = cType . unCSC
  getTypeString = typeString . unCSC
  
instance RenderType CSharpCode where
  typeFromData t s d = toCode $ td t s d

instance InternalTypeElim CSharpCode where
  type' = typeDoc . unCSC

instance ControlBlock CSharpCode where
  solveODE info opts = modify (addLibImport "Microsoft.Research.Oslo" . 
    addLangImport "System.Linq") >> 
    multiBlock [
      block [
        objDecNewNoParams optsVar,
        objVar optsVar (var "AbsoluteTolerance" float) &= absTol opts,
        objVar optsVar (var "AbsoluteTolerance" float) &= relTol opts],
      block [
        varDecDef sol (extFuncApp "Ode" (csODEMethod $ solveMethod opts) odeT 
        [tInit info, 
        newObj vec [initVal info], 
        lambda [iv, dv] (newObj vec [dv >>= (\dpv -> modify (setODEDepVars 
          [variableName dpv]) >> ode info)]),
        valueOf optsVar])],
      block [
        varDecDef points (objMethodCallNoParams spArray 
        (objMethodCall void (valueOf sol) "SolveFromToStep" 
          [tInit info, tFinal info, stepSize opts]) "ToArray"),
        listDecDef dv [],
        forEach sp (valueOf points) 
          (oneLiner $ valStmt $ listAppend (valueOf dv) (valueOf $ 
          objVar sp (var "X" (listInnerType $ onStateValue variableType dv))))]
    ]
    where optsVar = var "opts" (obj "Options")
          iv = indepVar info
          dv = depVar info
          odeT = obj "Idrasierable<SolPoint>"
          vec = obj "Vector"
          sol = var "sol" odeT
          spArray = arrayType (obj "SolPoint")
          points = var "points" spArray
          sp = var "sp" (obj "SolPoint")

instance UnaryOpSym CSharpCode where
  type UnaryOp CSharpCode = OpData
  notOp = C.notOp
  negateOp = G.negateOp
  sqrtOp = addSystemImport $ unOpPrec "Math.Sqrt"
  absOp = addSystemImport $ unOpPrec "Math.Abs"
  logOp = addSystemImport $ unOpPrec "Math.Log10"
  lnOp = addSystemImport $ unOpPrec "Math.Log"
  expOp = addSystemImport $ unOpPrec "Math.Exp"
  sinOp = addSystemImport $ unOpPrec "Math.Sin"
  cosOp = addSystemImport $ unOpPrec "Math.Cos"
  tanOp = addSystemImport $ unOpPrec "Math.Tan"
  asinOp = addSystemImport $ unOpPrec "Math.Asin"
  acosOp = addSystemImport $ unOpPrec "Math.Acos"
  atanOp = addSystemImport $ unOpPrec "Math.Atan"
  floorOp = addSystemImport $ unOpPrec "Math.Floor"
  ceilOp = addSystemImport $ unOpPrec "Math.Ceiling"

instance BinaryOpSym CSharpCode where
  type BinaryOp CSharpCode = OpData
  equalOp = G.equalOp
  notEqualOp = G.notEqualOp
  greaterOp = G.greaterOp
  greaterEqualOp = G.greaterEqualOp
  lessOp = G.lessOp
  lessEqualOp = G.lessEqualOp
  plusOp = G.plusOp
  minusOp = G.minusOp
  multOp = G.multOp
  divideOp = G.divideOp
  powerOp = addSystemImport $ powerPrec "Math.Pow"
  moduloOp = G.moduloOp
  andOp = C.andOp
  orOp = C.orOp

instance OpElim CSharpCode where
  uOp = opDoc . unCSC
  bOp = opDoc . unCSC
  uOpPrec = opPrec . unCSC
  bOpPrec = opPrec . unCSC

instance VariableSym CSharpCode where
  type Variable CSharpCode = VarData
  var = G.var
  staticVar = G.staticVar
  const = var
  extVar = CP.extVar
  self = C.self
  classVar = CP.classVar R.classVar
  extClassVar = classVar
  objVar = on2StateValues csObjVar
  objVarSelf = CP.objVarSelf
  arrayElem i = G.arrayElem (litInt i)
  iterVar = CP.iterVar

instance VariableElim CSharpCode where
  variableName = varName . unCSC
  variableType = onCodeValue varType

instance InternalVarElim CSharpCode where
  variableBind = varBind . unCSC
  variable = varDoc . unCSC

instance RenderVariable CSharpCode where
  varFromData b n t d = on2CodeValues (vard b n) t (toCode d)

instance ValueSym CSharpCode where
  type Value CSharpCode = ValData
  valueType = onCodeValue valType

instance Literal CSharpCode where
  litTrue = C.litTrue
  litFalse = C.litFalse
  litChar = G.litChar
  litDouble = G.litDouble
  litFloat = C.litFloat
  litInt = G.litInt
  litString = G.litString
  litArray = csLitList arrayType
  litList = csLitList listType

instance MathConstant CSharpCode where
  pi = CP.pi

instance VariableValue CSharpCode where
  valueOf v = join $ on2StateValues (\dvs vr -> maybe (G.valueOf v) (listAccess 
    (G.valueOf v) . litInt . toInteger) (elemIndex (variableName vr) dvs)) 
    getODEDepVars v

instance CommandLineArgs CSharpCode where
  arg n = G.arg (litInt n) argsList
  argsList = G.argsList "args"
  argExists i = listSize argsList ?> litInt (fromIntegral i)

instance NumericExpression CSharpCode where
  (#~) = unExpr' negateOp
  (#/^) = unExprNumDbl sqrtOp
  (#|) = unExpr absOp
  (#+) = binExpr plusOp
  (#-) = binExpr minusOp
  (#*) = binExpr multOp
  (#/) = binExpr divideOp
  (#%) = binExpr moduloOp
  (#^) = binExprNumDbl' powerOp

  log = unExprNumDbl logOp
  ln = unExprNumDbl lnOp
  exp = unExprNumDbl expOp
  sin = unExprNumDbl sinOp
  cos = unExprNumDbl cosOp
  tan = unExprNumDbl tanOp
  csc = G.csc
  sec = G.sec
  cot = G.cot
  arcsin = unExprNumDbl asinOp
  arccos = unExprNumDbl acosOp
  arctan = unExprNumDbl atanOp
  floor = unExpr floorOp
  ceil = unExpr ceilOp

instance BooleanExpression CSharpCode where
  (?!) = typeUnExpr notOp bool
  (?&&) = typeBinExpr andOp bool
  (?||) = typeBinExpr orOp bool

instance Comparison CSharpCode where
  (?<) = typeBinExpr lessOp bool
  (?<=) = typeBinExpr lessEqualOp bool
  (?>) = typeBinExpr greaterOp bool
  (?>=) = typeBinExpr greaterEqualOp bool
  (?==) = typeBinExpr equalOp bool
  (?!=) = typeBinExpr notEqualOp bool
  
instance ValueExpression CSharpCode where
  inlineIf = C.inlineIf

  funcAppMixedArgs = G.funcAppMixedArgs
  selfFuncAppMixedArgs = G.selfFuncAppMixedArgs dot self
  extFuncAppMixedArgs = CP.extFuncAppMixedArgs
  libFuncAppMixedArgs = C.libFuncAppMixedArgs
  newObjMixedArgs = G.newObjMixedArgs "new "
  extNewObjMixedArgs _ = newObjMixedArgs
  libNewObjMixedArgs = C.libNewObjMixedArgs

  lambda = G.lambda csLambda

  notNull = CP.notNull

instance RenderValue CSharpCode where
  inputFunc = addSystemImport $ mkStateVal string (text "Console.ReadLine()")
  printFunc = addSystemImport $ mkStateVal void (text "Console.Write")
  printLnFunc = addSystemImport $ mkStateVal void (text "Console.WriteLine")
  printFileFunc = on2StateValues (\v -> mkVal v . R.printFile "Write" . 
    RC.value) void
  printFileLnFunc = on2StateValues (\v -> mkVal v . R.printFile "WriteLine" . 
    RC.value) void
  
  cast = csCast

  call = G.call (colon <> space)
  
  valFromData p t d = on2CodeValues (vd p) t (toCode d)
  
instance ValueElim CSharpCode where
  valuePrec = valPrec . unCSC
  value = val . unCSC
  
instance InternalValueExp CSharpCode where
  objMethodCallMixedArgs' = G.objMethodCall

instance FunctionSym CSharpCode where
  type Function CSharpCode = FuncData
  func = G.func
  objAccess = G.objAccess

instance GetSet CSharpCode where
  get = G.get
  set = G.set

instance List CSharpCode where
  listSize = C.listSize
  listAdd = G.listAdd
  listAppend = G.listAppend
  listAccess = G.listAccess
  listSet = G.listSet
  indexOf = CP.indexOf "IndexOf"
  
instance InternalList CSharpCode where
  listSlice' = M.listSlice

instance Iterator CSharpCode where
  iterBegin = G.iterBegin
  iterEnd = G.iterEnd

instance InternalGetSet CSharpCode where
  getFunc = G.getFunc
  setFunc = G.setFunc

instance InternalListFunc CSharpCode where
  listSizeFunc = funcFromData (R.func (text "Count")) int
  listAddFunc _ = CP.listAddFunc "Insert"
  listAppendFunc = G.listAppendFunc "Add"
  listAccessFunc = CP.listAccessFunc
  listSetFunc = CP.listSetFunc R.listSetFunc

instance InternalIterator CSharpCode where
  iterBeginFunc _ = error $ CP.iterBeginError csName
  iterEndFunc _ = error $ CP.iterEndError csName
    
instance RenderFunction CSharpCode where
  funcFromData d = onStateValue (onCodeValue (`fd` d))
  
instance FunctionElim CSharpCode where
  functionType = onCodeValue fType
  function = funcDoc . unCSC

instance InternalAssignStmt CSharpCode where
  multiAssign _ _ = error $ C.multiAssignError csName

instance InternalIOStmt CSharpCode where
  printSt _ _ = CP.printSt
  
instance InternalControlStmt CSharpCode where
  multiReturn _ = error $ C.multiReturnError csName 

instance RenderStatement CSharpCode where
  stmt = G.stmt
  loopStmt = G.loopStmt

  emptyStmt = G.emptyStmt
  
  stmtFromData d t = toCode (d, t)

instance StatementElim CSharpCode where
  statement = fst . unCSC
  statementTerm = snd . unCSC

instance StatementSym CSharpCode where
  type Statement CSharpCode = (Doc, Terminator)
  valStmt = G.valStmt Semi
  multi = onStateList (onCodeList R.multiStmt)

instance AssignStatement CSharpCode where
  assign = G.assign Semi
  (&-=) = M.decrement
  (&+=) = G.increment
  (&++) = C.increment1
  (&--) = M.decrement1

instance DeclStatement CSharpCode where
  varDec v = zoom lensMStoVS v >>= (\v' -> csVarDec (variableBind v') $ 
    C.varDec static dynamic v)
  varDecDef = C.varDecDef
  listDec n v = zoom lensMStoVS v >>= (\v' -> C.listDec (R.listDec v') 
    (litInt n) v)
  listDecDef = CP.listDecDef
  arrayDec n = CP.arrayDec (litInt n)
  arrayDecDef = CP.arrayDecDef
  objDecDef = varDecDef
  objDecNew = G.objDecNew
  extObjDecNew = C.extObjDecNew
  constDecDef = CP.constDecDef
  funcDecDef = csFuncDecDef

instance IOStatement CSharpCode where
  print      = G.print False Nothing printFunc
  printLn    = G.print True  Nothing printLnFunc
  printStr   = G.print False Nothing printFunc   . litString
  printStrLn = G.print True  Nothing printLnFunc . litString

  printFile f      = G.print False (Just f) (printFileFunc f)
  printFileLn f    = G.print True  (Just f) (printFileLnFunc f)
  printFileStr f   = G.print False (Just f) (printFileFunc f)   . litString
  printFileStrLn f = G.print True  (Just f) (printFileLnFunc f) . litString

  getInput v = v &= csInput (onStateValue variableType v) inputFunc
  discardInput = C.discardInput csDiscardInput
  getFileInput f v = v &= csInput (onStateValue variableType v) (csFileInput f)
  discardFileInput f = valStmt $ csFileInput f

  openFileR = CP.openFileR csOpenFileR
  openFileW = CP.openFileW csOpenFileWorA
  openFileA = CP.openFileA csOpenFileWorA
  closeFile = G.closeFile "Close"

  getFileInputLine = getFileInput
  discardFileLine = CP.discardFileLine "ReadLine"
  getFileInputAll f v = while ((f $. funcFromData (text ".EndOfStream") bool) 
    ?!) (oneLiner $ valStmt $ listAppend (valueOf v) (csFileInput f))

instance StringStatement CSharpCode where
  stringSplit d vnew s = assign vnew $ newObj (listType string) 
    [s $. func "Split" (listType string) [litChar d]]

  stringListVals = M.stringListVals
  stringListLists = M.stringListLists

instance FuncAppStatement CSharpCode where
  inOutCall = csInOutCall funcApp
  selfInOutCall = csInOutCall selfFuncApp
  extInOutCall m = csInOutCall (extFuncApp m)

instance CommentStatement CSharpCode where
  comment = G.comment commentStart

instance ControlStatement CSharpCode where
  break = toState $ mkStmt R.break
  continue = toState $ mkStmt R.continue

  returnStmt = G.returnStmt Semi
  
  throw msg = do
    modify (addLangImport "System")
    G.throw csThrowDoc Semi msg

  ifCond = G.ifCond bodyStart elseIfLabel bodyEnd
  switch = C.switch

  ifExists = M.ifExists

  for = C.for bodyStart bodyEnd
  forRange = M.forRange
  forEach = CP.forEach bodyStart bodyEnd (text "foreach") inLabel 
  while = C.while bodyStart bodyEnd

  tryCatch = G.tryCatch csTryCatch

instance StatePattern CSharpCode where 
  checkState = M.checkState

instance ObserverPattern CSharpCode where
  notifyObservers = M.notifyObservers

instance StrategyPattern CSharpCode where
  runStrategy = M.runStrategy

instance ScopeSym CSharpCode where
  type Scope CSharpCode = Doc
  private = toCode R.private
  public = toCode R.public

instance RenderScope CSharpCode where
  scopeFromData _ = toCode
  
instance ScopeElim CSharpCode where
  scope = unCSC

instance MethodTypeSym CSharpCode where
  type MethodType CSharpCode = TypeData
  mType = zoom lensMStoVS 
  construct = G.construct

instance ParameterSym CSharpCode where
  type Parameter CSharpCode = ParamData
  param = G.param R.param
  pointerParam = param

instance RenderParam CSharpCode where
  paramFromData v d = on2CodeValues pd v (toCode d)

instance ParamElim CSharpCode where
  parameterName = variableName . onCodeValue paramVar
  parameterType = variableType . onCodeValue paramVar
  parameter = paramDoc . unCSC

instance MethodSym CSharpCode where
  type Method CSharpCode = MethodData
  method = G.method
  getMethod = G.getMethod
  setMethod = G.setMethod
  constructor ps is b = getClassName >>= (\n -> G.constructor n ps is b)

  docMain = CP.docMain
 
  function = G.function
  mainFunction = CP.mainFunction string "Main"

  docFunc = G.docFunc

  inOutMethod n = csInOut (method n)

  docInOutMethod n = CP.docInOutFunc (inOutMethod n)

  inOutFunc n = csInOut (function n)

  docInOutFunc n = CP.docInOutFunc (inOutFunc n)

instance RenderMethod CSharpCode where
  intMethod m n s p t ps b = do
    modify (if m then setCurrMain else id)
    tp <- t
    pms <- sequence ps
    toCode . mthd . R.method n s p tp pms <$> b
  intFunc = C.intFunc
  commentedFunc cmt m = on2StateValues (on2CodeValues updateMthd) m 
    (onStateValue (onCodeValue R.commentedItem) cmt)
    
  destructor _ = error $ CP.destructorError csName
  
instance MethodElim CSharpCode where
  method = mthdDoc . unCSC

instance StateVarSym CSharpCode where
  type StateVar CSharpCode = Doc
  stateVar = CP.stateVar
  stateVarDef _ = CP.stateVarDef
  constVar _ = CP.constVar empty
  
instance StateVarElim CSharpCode where
  stateVar = unCSC

instance ClassSym CSharpCode where
  type Class CSharpCode = Doc
  buildClass = G.buildClass
  extraClass = buildClass
  implementingClass = G.implementingClass

  docClass = G.docClass

instance RenderClass CSharpCode where
  intClass = CP.intClass R.class'

  inherit n = toCode $ maybe empty ((colon <+>) . text) n
  implements is = toCode $ colon <+> text (intercalate ", " is)

  commentedClass = G.commentedClass
  
instance ClassElim CSharpCode where
  class' = unCSC

instance ModuleSym CSharpCode where
  type Module CSharpCode = ModData
  buildModule n = CP.buildModule' n langImport
  
instance RenderMod CSharpCode where
  modFromData n = G.modFromData n (toCode . md n)
  updateModuleDoc f = onCodeValue (updateMod f)
  
instance ModuleElim CSharpCode where
  module' = modDoc . unCSC

instance BlockCommentSym CSharpCode where
  type BlockComment CSharpCode = Doc
  blockComment lns = toCode $ R.blockCmt lns blockCmtStart blockCmtEnd
  docComment = onStateValue (\lns -> toCode $ R.docCmt lns docCmtStart 
    blockCmtEnd)

instance BlockCommentElim CSharpCode where
  blockComment' = unCSC

addSystemImport :: VS a -> VS a
addSystemImport = (>>) $ modify (addLangImportVS "System")

csName :: String
csName = "C#"

csODEMethod :: ODEMethod -> String
csODEMethod RK45 = "RK547M"
csODEMethod BDF = "GearBDF"
csODEMethod _ = error "Chosen ODE method unavailable in C#"

csImport :: Label -> Doc
csImport n = text ("using " ++ n) <> endStatement

csInfileType :: (RenderSym r) => VSType r
csInfileType = modifyReturn (addLangImportVS "System.IO") $ 
  typeFromData File "StreamReader" (text "StreamReader")

csOutfileType :: (RenderSym r) => VSType r
csOutfileType = modifyReturn (addLangImportVS "System.IO") $ 
  typeFromData File "StreamWriter" (text "StreamWriter")

csLitList :: (RenderSym r) => (VSType r -> VSType r) -> VSType r -> [SValue r] 
  -> SValue r
csLitList f t = on1StateValue1List (\lt es -> mkVal lt (new <+> RC.type' lt <+> 
  braces (valueList es))) (f t)

csLambda :: (RenderSym r) => [r (Variable r)] -> r (Value r) -> Doc
csLambda ps ex = parens (variableList ps) <+> text "=>" <+> RC.value ex

csCast :: VSType CSharpCode -> SValue CSharpCode -> SValue CSharpCode
csCast t v = join $ on2StateValues (\tp vl -> csCast' (getType tp) (getType $ 
  valueType vl) tp vl) t v
  where csCast' Double String _ _ = funcApp "Double.Parse" double [v]
        csCast' Float String _ _ = funcApp "Single.Parse" float [v]
        csCast' _ _ tp vl = mkStateVal t (R.castObj (R.cast (RC.type' tp)) 
          (RC.value vl))

csFuncDecDef :: (RenderSym r) => SVariable r -> [SVariable r] -> SValue r -> 
  MSStatement r
csFuncDecDef v ps r = do
  vr <- zoom lensMStoVS v
  pms <- mapM (zoom lensMStoVS) ps
  b <- oneLiner $ returnStmt r
  return $ mkStmtNoEnd $ RC.type' (variableType vr) <+> text (variableName vr) 
    <> parens (variableList pms) <+> bodyStart $$ indent (RC.body b) $$ bodyEnd 

csThrowDoc :: (RenderSym r) => r (Value r) -> Doc
csThrowDoc errMsg = text "throw new" <+> text "Exception" <> 
  parens (RC.value errMsg)

csTryCatch :: (RenderSym r) => r (Body r) -> r (Body r) -> Doc
csTryCatch tb cb = vcat [
  text "try" <+> lbrace,
  indent $ RC.body tb,
  rbrace <+> text "catch" <+> 
    lbrace,
  indent $ RC.body cb,
  rbrace]

csDiscardInput :: (RenderSym r) => r (Value r) -> Doc
csDiscardInput = RC.value

csFileInput :: (RenderSym r) => SValue r -> SValue r
csFileInput = onStateValue (\f -> mkVal (valueType f) (RC.value f <> dot <> 
  text "ReadLine()"))

csInput :: (RenderSym r) => VSType r -> SValue r -> SValue r
csInput tp inF = do
  t <- tp
  inFn <- inF
  let v = mkVal t $ text (csInput' (getType t)) <> parens (RC.value inFn)
  csInputImport (getType t) (return v)
  where csInput' Integer = "Int32.Parse"
        csInput' Float = "Single.Parse"
        csInput' Double = "Double.Parse"
        csInput' Boolean = "Boolean.Parse"
        csInput' String = ""
        csInput' Char = "Char.Parse"
        csInput' _ = error "Attempt to read value of unreadable type"
        csInputImport t = if t `elem` [Integer, Float, Double, Boolean, Char] 
          then addSystemImport else id

csOpenFileR :: (RenderSym r) => SValue r -> VSType r -> SValue r
csOpenFileR n r = newObj r [n]

csOpenFileWorA :: (RenderSym r) => SValue r -> VSType r -> SValue r -> SValue r
csOpenFileWorA n w a = newObj w [n, a] 

csRef :: Doc -> Doc
csRef p = text "ref" <+> p

csOut :: Doc -> Doc
csOut p = text "out" <+> p

csInOutCall :: (Label -> VSType CSharpCode -> [SValue CSharpCode] -> 
  SValue CSharpCode) -> Label -> [SValue CSharpCode] -> [SVariable CSharpCode] 
  -> [SVariable CSharpCode] -> MSStatement CSharpCode
csInOutCall f n ins [out] [] = assign out $ f n (onStateValue variableType out) 
  ins
csInOutCall f n ins [] [out] = assign out $ f n (onStateValue variableType out) 
  (valueOf out : ins)
csInOutCall f n ins outs both = valStmt $ f n void (map (onStateValue 
  (onCodeValue (updateValDoc csRef)) . valueOf) both ++ ins ++ map 
  (onStateValue (onCodeValue (updateValDoc csOut)) . valueOf) outs)

csVarDec :: Binding -> MSStatement CSharpCode -> MSStatement CSharpCode
csVarDec Static _ = error "Static variables can't be declared locally to a function in C#. Use stateVar to make a static state variable instead."
csVarDec Dynamic d = d

csObjVar :: (RenderSym r) => r (Variable r) -> r (Variable r) -> r (Variable r)
csObjVar o v = csObjVar' (variableBind v)
  where csObjVar' Static = error 
          "Cannot use objVar to access static variables through an object in C#"
        csObjVar' Dynamic = mkVar (variableName o ++ "." ++ variableName v) 
          (variableType v) (R.objVar (RC.variable o) (RC.variable v))

csInOut :: (CSharpCode (Scope CSharpCode) -> CSharpCode (Permanence CSharpCode) 
    -> VSType CSharpCode -> [MSParameter CSharpCode] -> MSBody CSharpCode -> 
    SMethod CSharpCode)
  -> CSharpCode (Scope CSharpCode) -> CSharpCode (Permanence CSharpCode) -> 
  [SVariable CSharpCode] -> [SVariable CSharpCode] -> [SVariable CSharpCode] -> 
  MSBody CSharpCode -> SMethod CSharpCode
csInOut f s p ins [v] [] b = f s p (onStateValue variableType v) (map param ins)
  (on3StateValues (on3CodeValues surroundBody) (varDec v) b (returnStmt $ 
  valueOf v))
csInOut f s p ins [] [v] b = f s p (onStateValue variableType v) 
  (map param $ v : ins) (on2StateValues (on2CodeValues appendToBody) b 
  (returnStmt $ valueOf v))
csInOut f s p ins outs both b = f s p void (map (onStateValue (onCodeValue 
  (updateParam csRef)) . param) both ++ map param ins ++ map (onStateValue 
  (onCodeValue (updateParam csOut)) . param) outs) b
