module Drasil.GlassBR.Unitals where

import Drasil.GlassBR.Units
import Drasil.GlassBR.Concepts

import Language.Drasil
import Data.Drasil.SI_Units
import Data.Drasil.Utils(symbolMapFun)
import Control.Lens((^.))
import Prelude hiding (log, id)
import Data.Drasil.SentenceStructures (foldlSent)

--FIXME: Many of the current terms can be separated into terms and defns!

{--}

glassBRSymbolsWithDefns :: [UnitalChunk]
glassBRSymbolsWithDefns = [mod_elas]

mod_elas :: UnitalChunk
mod_elas    = uc' "mod_elas"      (nounPhraseSP "modulus of elasticity of glass")
  "The ratio of tensile stress to tensile strain of glass." cE kilopascal

{--}

gbConstrained :: [ConstrainedChunk]
gbConstrained = gbInputs ++ [prob_br]

plate_len, plate_width, char_weight, pb_tol, tNT, standOffDist, nom_thick, glass_type, prob_br :: ConstrainedChunk

{--}

gbInputs :: [ConstrainedChunk]
gbInputs = [plate_len, plate_width, char_weight, pb_tol, tNT, standOffDist, nom_thick, glass_type]

plate_len = cuc "plate_len" (nounPhraseSP "plate length (long dimension)")
  lA millimetre Rational 
  [ physc $ \c -> c :> (Dbl 0),
    physc $ \c -> (c :/ (C plate_width)) :> (Dbl 1),
    sfwrc $ \c -> (C dim_min) :<= c,
    sfwrc $ \c -> c :<= (C dim_max),
    sfwrc $ \c -> (c :/ (C plate_width)) :< (C ar_max) ]

plate_width = cuc "plate_width" (nounPhraseSP "plate width (short dimension)")
  lB millimetre Rational
  [ physc $ \c -> c :> (Dbl 0),
    physc $ \c -> c :< (C plate_len),
    sfwrc $ \c -> (C dim_min) :<= c,
    sfwrc $ \c -> c :<= (C dim_max),
    sfwrc $ \c -> ((C plate_len) :/ c) :< (C ar_max) ]

pb_tol = cvc "pb_tol" (nounPhraseSP "tolerable probability of breakage") 
  (sub cP (Atomic "btol")) Rational
  [ physc $ \c -> (Dbl 0) :< c ,
    physc $ \c -> c :< (Dbl 1) ]

char_weight = cuc "char_weight" (nounPhraseSP "charge weight") 
  lW kilogram Rational
  [ physc $ \c -> c :>= (Dbl 0),
    sfwrc $ \c -> (C cWeightMax) :<= c,
    sfwrc $ \c -> c :<= (C cWeightMin) ]

tNT = cvc "tNT" (nounPhraseSP "TNT equivalent factor")
  (Atomic "TNT") Rational
  [ physc $ \c -> c :> (Dbl 0) ]

standOffDist = cuc "standOffDist" (nounPhraseSP "stand off distance") 
  (Atomic "SD") metre Rational
  [ physc $ \c -> c :> (Dbl 0),
    sfwrc $ \c -> (C sd_min) :< c,
    sfwrc $ \c -> c :< (C sd_max) ]

nom_thick = cuc "nom_thick" (nounPhraseSP $ "nominal thickness t in" ++
  " {2.5, 2.7, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0, 12.0, 16.0, 19.0, 22.0}")
  lT millimetre Rational
  [ physc $ \c -> (c := (V "2.5")) :|| (c := (V "2.7")) :|| (c := (V "3.0")) :|| (c := (V "4.0"))
                  :|| (c := (V "5.0")) :|| (c := (V "6.0")) :|| (c := (V "8.0")) :|| (c := (V "10.0"))
                  :|| (c := (V "12.0")) :|| (c := (V "16.0")) :|| (c := (V "19.0")) :|| (c := (V "22.0")) ]

glass_type  = cvc "glass_type"    (nounPhraseSP "glass type, g in {AN, HS, FT}")
  lG String
  [ physc $ \c -> (c := (V "AN")) :|| (c := (V "HS")) :|| (c := (V "FT")) ]
--FIXME:Creating variables increases duplication; find a way to incorporate preexisting chunks in constraints

{--}

gbOutputs :: [QSWrapper]
gbOutputs = map qs [is_safe1, is_safe2] ++ map qs [prob_br]

prob_br = cvc "prob_br" (nounPhraseSP "probability of breakage")
  (sub cP lB) Rational
  [ physc $ \c -> (Dbl 0) :< c,
    physc $ \c -> c :< (Dbl 1) ]

{--}

glassBRSymbols :: [UnitaryChunk]
glassBRSymbols = [dim_max, dim_min, act_thick, sflawParamK, sflawParamM,
  demand, sdx, sdy, sdz, sd_max, sd_min, load_dur, cWeightMax, cWeightMin,
  eqTNTWeight]

dim_max, dim_min, act_thick, sflawParamK, sflawParamM, demand, sdx, sdy,
  sdz, sd_max, sd_min, load_dur, cWeightMax, cWeightMin, eqTNTWeight :: UnitaryChunk

dim_max     = unitary "dim_max"     (nounPhraseSP "maximum value for one of the dimensions of the glass plate") 
  (sub lD (Atomic "max")) millimetre Real
dim_min     = unitary "dim_min"     (nounPhraseSP "minimum value for one of the dimensions of the glass plate") 
  (sub lD (Atomic "min")) millimetre Real
act_thick   = unitary "act_thick"   (nounPhraseSP "actual thickness")
  lH millimetre Rational
sflawParamK = unitary "sflawParamK" (nounPhraseSP "surface flaw parameter") --parameterize?
  lK sFlawPU Rational
sflawParamM = unitary "sflawParamM" (nounPhraseSP "surface flaw parameter") --parameterize?
  lM sFlawPU Integer
demand      = unitary "demand"      (nounPhraseSP "applied load (demand)")
  lQ kilopascal Rational --correct Space used?
sdx = unitary "sdx" (nounPhraseSP "stand off distance (x-component)")
  (sub (standOffDist ^. symbol) lX) metre Rational
sdy = unitary "sdy" (nounPhraseSP "stand off distance (y-component)")
  (sub (standOffDist ^. symbol) lY) metre Rational
sdz = unitary "sdz" (nounPhraseSP "stand off distance (z-component)")
  (sub (standOffDist ^. symbol) lZ) metre Rational
sd_max      = unitary "sd_max"      (nounPhraseSP "maximum stand off distance permissible for input") 
  (sub (standOffDist ^. symbol) (Atomic "max")) metre Real
sd_min      = unitary "sd_min"      (nounPhraseSP "minimum stand off distance permissible for input") 
  (sub (standOffDist ^. symbol) (Atomic "min")) metre Real
load_dur    = unitary "load_dur"    (nounPhraseSP "duration of load")
  (sub lT lD) second Integer
cWeightMax  = unitary "cWeightMax"  (nounPhraseSP "maximum permissible input charge weight")
  (sub (char_weight ^. symbol) (Atomic "max")) kilogram Rational
cWeightMin  = unitary "cWeightMin"  (nounPhraseSP "minimum permissible input charge weight")
  (sub (char_weight ^. symbol) (Atomic "min")) kilogram Rational
eqTNTWeight = unitary "eqTNTWeight" (nounPhraseSP "explosive mass in equivalent weight of TNT") --replace with short TNT?
  (sub (char_weight ^. symbol) (tNT ^. symbol)) kilogram Rational

{-Quantities-}

glassBRUnitless :: [VarChunk]
glassBRUnitless = [ar_max, risk_fun, is_safe1, is_safe2, stressDistFac, sdf_tol,
  dimlessLoad, tolLoad, lRe, loadSF, gTF, lDurFac]

ar_max, risk_fun, is_safe1, is_safe2, stressDistFac, sdf_tol,
  dimlessLoad, tolLoad, lRe, loadSF, gTF, lDurFac :: VarChunk

ar_max      = vc "ar_max"        (nounPhraseSP "maximum aspect ratio")
  (sub (Atomic "AR") (Atomic "max")) Rational
risk_fun    = makeVC "risk_fun"      (nounPhraseSP "risk of failure") cB
is_safe1    = vc "is_safe1"      (nounPhraseSP $ "true when calculated probability is " ++
  "less than tolerable probability") (Concat [Atomic "is", Special UScore, 
  Atomic "safe1"]) Boolean
is_safe2    = vc "is_safe2"      (nounPhraseSP $ "true when load resistance (capacity) " ++
  "is greater than load (demand)") (Concat [Atomic "is", Special UScore, 
  Atomic "safe2"]) Boolean
stressDistFac = makeVC "stressDistFac"  (nounPhraseSP "stress distribution factor (Function)") cJ
sdf_tol     = makeVC "sdf_tol" (nounPhraseSP "stress distribution factor (Function) based on Pbtol")
  (sub (stressDistFac ^. symbol) (Atomic "tol"))
dimlessLoad = makeVC "dimlessLoad"   (nounPhraseSP "dimensionless load") (hat lQ)
tolLoad     = makeVC "tolLoad"       (nounPhraseSP "tolerable load")
  (sub (dimlessLoad ^. symbol) (Atomic "tol"))
lRe         = makeVC "lRe"           (lResistance ^. term) (Atomic "LR")
loadSF      = vc "loadSF"        (lShareFac ^. term) (Atomic "LSF") Integer
gTF         = vc "gTF"           (glassTypeFac_ ^. term) (Atomic "GTF") Integer
lDurFac     = makeVC "lDurFac" (loadDurFactor ^. term) (Atomic "LDF")

terms :: [ConceptChunk]
terms = [aspectRatio, glBreakage, lite, glassTy,
  annealedGl, fTemperedGl, hStrengthGl, glTyFac, lateral, load, specDeLoad,
  loadResis, longDurLoad, nonFactoredL, glassWL, shortDurLoad, loadShareFac,
  probBreak, specA, blastResisGla, eqTNTChar, sD]

aspectRatio, glBreakage, lite, glassTy, annealedGl, fTemperedGl, hStrengthGl,
  glTyFac, lateral, load, specDeLoad, loadResis, longDurLoad, nonFactoredL,
  glassWL, shortDurLoad, loadShareFac, probBreak, specA, blastResisGla, eqTNTChar,
  sD, blast, blastTy, glassGeo, capacity, demandq, safeMessage,   notSafe, bomb,
  explosion :: ConceptChunk

--FIXME: Why are there multiple copies of aspect ratio, glass type factor, etc.?
aspectRatio   = dcc "aspectRatio" (aspectR ^. term)
  ("The ratio of the long dimension of the glass to the short dimension of " ++
    "the glass. For glass supported on four sides, the aspect ratio is " ++
    "always equal to or greater than 1.0. For glass supported on three " ++
    "sides, the ratio of the length of one of the supported edges " ++
    "perpendicular to the free edge, to the length of the free edge, is " ++
    "equal to or greater than 0.5.")
glBreakage    = dcc "glBreakage"  (nounPhraseSP "glass breakage")
  ("The fracture or breakage of any lite or ply in monolithic, laminated, " ++
    "or insulating glass.")
lite          = dcc "lite"        (cn' "lite") --is used in the plural form
  ("Pieces of glass that are cut, prepared, and used to create the window " ++
    "or door.")
glassTy       = dcc "glassTy"     (cn' "glass types") "type of glass"
annealedGl    = dcc "annealedGl"  (annealedGlass ^. term)
  ("A flat, monolithic, glass lite which has uniform thickness where the " ++
    "residual surface stresses are almost zero, as defined in [5].")
fTemperedGl   = dcc "fTemperedGl"          (fullyTGlass ^. term)
  ("A flat and monolithic, glass lite of uniform thickness that has been " ++
    "subjected to a special heat treatment process where the residual " ++
    "surface compression is not less than 69 MPa (10 000 psi) or the edge " ++
    "compression not less than 67 MPa (9700 psi), as defined in [6].")
hStrengthGl   = dcc "hStrengthGl"          (heatSGlass ^. term)
  ("A flat, monolithic, glass lite of uniform thickness that has been " ++
    "subjected to a special heat treatment process where the residual " ++
    "surface compression is not less than 24 MPa (3500psi) or greater " ++
    "than 52 MPa (7500 psi), as defined in [6].")
glTyFac       = dccWDS "glTyFac"      (nounPhraseSP "glass type factor") 
  (foldlSent [S "A multiplying factor for adjusting the", (getAcc lResistance), 
  S "of different glass type, that is,", (getAcc annealedGlass) `sC` 
  (getAcc heatSGlass) `sC` S "or", (getAcc fullyTGlass), S "in monolithic glass" `sC`
  (getAcc lGlass), S "(Laminated Glass)" `sC` S "or", (getAcc iGlass), 
  S "(Insulating Glass) constructions"])
lateral       = dcc "lateral"     (nounPhraseSP "lateral") "Perpendicular to the glass surface."
load          = dcc "load"        (nounPhraseSP "load") "A uniformly distributed lateral pressure."
specDeLoad    = dcc "specDeLoad"  (nounPhraseSP "specified design load")
  ("The magnitude in kPa (psf), type (for example, wind or snow) and " ++
    "duration of the load given by the specifying authority.")
loadResis     = dcc "loadResis"          (lResistance ^. term)
  ("The uniform lateral load that a glass construction can sustain based " ++
    "upon a given probability of breakage and load duration as defined in " ++
    "[4 (pg. 1, 53)], following A2 and A1 respectively.")
longDurLoad   = dcc "longDurLoad"        (nounPhraseSP "long duration load")
  ("Any load lasting approximately 30 days.")
nonFactoredL  = dccWDS "nonFactoredL"    (nounPhraseSP "non-factored load")
  (foldlSent [S "Three second duration uniform load associated with a probability of",
    S "breakage less than or equal to 8", (plural lite), S "per 1000 for monolithic",
    (getAcc annealedGlass), S "glass"])
glassWL       = dcc "glassWL"     (nounPhraseSP "glass weight load")
  ("The dead load component of the glass weight.")
shortDurLoad  = dcc "shortDurLoad"       (nounPhraseSP "short duration load")
  "Any load lasting 3s or less."
loadShareFac  = dccWDS "loadShareFac"  (lShareFac ^. term)
  (foldlSent [S "A multiplying factor derived from the load sharing between the double",
  S "glazing, of equal or different thickness's and types (including the",
  S "layered behaviour of", (getAcc lGlass), S "under long duration",
  S "loads), in a sealed", (getAcc iGlass), S "unit"])
probBreak     = dcc "probBreak"       (prob_br ^. term)
  ("The fraction of glass lites or plies that would break at the first " ++
    "occurrence of a specified load and duration, typically expressed " ++
    "in lites per 1000.")
specA         = dcc "specA"       (nounPhraseSP "specifying authority")
  ("The design professional responsible for interpreting applicable " ++
    "regulations of authorities having jurisdiction and considering " ++
    "appropriate site specific factors to determine the appropriate " ++
    "values used to calculate the specified design load, and furnishing " ++
    "other information required to perform this practice.")
blastResisGla = dcc "blastResisGla"    (nounPhraseSP "blast resistant glazing")
  ("Glazing that provides protection against air blast pressure generated " ++
    "by explosions.")
eqTNTChar     = dcc "eqTNTChar"   (nounPhraseSP "equivalent TNT charge mass")
  ("Mass of TNT placed on the ground in a hemisphere that represents the " ++
    "design explosive threat.")
sD            = dccWDS "sD"       (standOffDist ^. term) 
  (S "The distance from the glazing surface to the centroid of a hemispherical" +:+
   S "high explosive charge. It is represented by the coordinates (SDx, SDy, SDz)")
blast         = dcc "blast"       (nounPhraseSP "blast") 
  "any kind of man-made explosion"
blastTy       = dcc "blastTy"     (nounPhraseSP "blast type")
  ("The blast type input includes parameters like weight of charge, TNT " ++
    "equivalent factor and stand off distance from the point of explosion.")
glassGeo      = dcc "glassGeo"    (nounPhraseSP "glass geometry")
  ("The glass geometry based inputs include the dimensions of the glass " ++
    "plane, glass type and response type.")
capacity      = dcc "capacity"    (nounPhraseSP "capacity")
  "the load resistance calculated"
demandq       = dcc "demandq"     (nounPhraseSP "demand") 
  "3 second duration equivalent pressure"
safeMessage   = dcc "safeMessage" (nounPhraseSP "safe")
  ("For the given input parameters, the glass is considered safe.")
notSafe       = dcc "notSafe"     (nounPhraseSP "not safe")
  ("For the given input parameters, the glass is NOT considered safe.")
bomb          = dcc "bomb"        (nounPhraseSP "bomb") ("a container filled with" ++
  " a destructive substance designed to exlode on impact or via detonation")
explosion     = dcc "explosion"   (nounPhraseSP "explosion") 
  "a destructive shattering of something"

-- hack; needs to be removed eventually
temporary :: [ConVar]
temporary = [nonFactorL, glassTypeFac_]

nonFactorL, glassTypeFac_ :: ConVar
nonFactorL     = cvR (nonFactoredL) (Atomic "NFL")
glassTypeFac_  = cvR (glTyFac) (Atomic "GTF")

this_symbols :: [QSWrapper]
this_symbols = ((map qs glassBRSymbolsWithDefns) ++ (map qs glassBRSymbols)
  ++ (map qs glassBRUnitless) ++ (map qs gbInputs))

temporaryLOSymbols :: [QSWrapper]
temporaryLOSymbols = this_symbols ++ map qs (temporary)

gbSymbMap :: SymbolMap
gbSymbMap = symbolMap temporaryLOSymbols

gbSymbMapD :: QDefinition -> Contents
gbSymbMapD term_ = (symbolMapFun gbSymbMap Data) term_

gbSymbMapT :: RelationConcept -> Contents
gbSymbMapT term_ = (symbolMapFun gbSymbMap Theory) term_