{-# Language Rank2Types #-}
module Drasil.DocumentLanguage.RefHelpers
  ( ModelDB, tmRefDB, gdRefDB, ddRefDB, imRefDB
  , mdb, modelsFromDB
  ) where

import Language.Drasil

import Control.Lens ((^.), Simple, Lens)
import Data.List (sortBy)
import Data.Function (on)
import qualified Data.Map as Map (elems, lookup)

modelsFromDB :: RefMap a -> [a]
modelsFromDB db = dropNums $ sortBy (compare `on` snd) elemPairs
  where elemPairs = Map.elems db
        dropNums = map fst

-- Trying not to add to RefDB since these are recipe-specific content-types for
-- the SmithEtAl Template recipe.
data ModelDB = MDB
             { tmRefDB :: RefMap TheoryModel
             , gdRefDB :: RefMap GenDefn
             , ddRefDB :: RefMap QDefinition
             , imRefDB :: RefMap InstanceModel
             }

mdb :: [TheoryModel] -> [GenDefn] -> [QDefinition] -> [InstanceModel] -> ModelDB
mdb tms gds dds ims = MDB
  (simpleMap tms) (simpleMap gds) (simpleMap dds) (simpleMap ims)