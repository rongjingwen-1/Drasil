module Drasil.NoPCM.Definitions where --whole file is used

import Language.Drasil

import Data.Drasil.Concepts.Documentation (thModel, srs, physSyst,
  requirement, inModel, likelyChg, genDefn, goalStmt, assumption,
  dataDefn)
import Data.Drasil.Concepts.Math (ode)

--Common Terms
coil, tank, water, ht_trans :: NamedChunk

coil        = npnc "coil"           (cn' "coil")
tank        = npnc "tank"           (cn' "tank")
water       = npnc "water"          (cn "water")
ht_trans    = npnc "heat transfer"  (cn "heat transfer") --Not really a nounphase,
                                                         --just a hack to get RefSec to work

srs_swhs :: ConceptChunk -- Used to make the title of the paper
srs_swhs = dcc "srs_swhs" (nounPhraseSP 
  "Solar Water Heating Systems")
  "SWHS"
  
sWHS, sWHT :: CI

sWHS  = commonIdea "sWHS"  (cn' "solar water heating system")  "SWHS"
sWHT  = commonIdea "sWHT"  (cn' "solar water heating tank")    "SWHT"  
  
----Acronyms-----
acronyms :: [CI]
acronyms = [assumption, dataDefn, genDefn, goalStmt, inModel, likelyChg, ode, 
            physSyst, requirement, srs, sWHS, thModel]