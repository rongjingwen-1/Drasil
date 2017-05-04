module Data.Drasil.Concepts.Math where

import Language.Drasil

gradient, norm_vect, orient, unit_vect, euclid_norm, matrix :: ConceptChunk

ode :: CINP

--FIXME: Make some of these definitions better.
gradient  = dcc "gradient" (cn' "gradient") "gradient operator"
norm_vect = dcc "norm_vect" (cn' "normal") "unit outward normal vector for a surface"
-- could use better name for this? namespace collision when using orientation
orient = dcc "orientation" (cn' "orientation") "orientation"
unit_vect = dcc "unit_vect" (cn' "unit vector") "unit vector"
euclid_norm = dcc "euclid_norm" (cn' "Euclidean Norm") "Euclidean Norm"

matrix = dcc "matrix" (cn' "matrix") "matrix"

--FIXME: use nounphrase instead of cn'
ode       = commonINP "ode" (cn' "Ordinary Differential Equation") "ODE"

