{-# OPTIONS -Wall #-} 
module Config where
import ASTInternal (OutLang(..), DocParams(..))

outLang :: OutLang
outLang = CLang

-- precision :: Precision
-- precision = Double

expandSymbols :: Bool
expandSymbols = True

srsTeXParams,lpmTeXParams :: [DocParams]
srsTeXParams = defaultSRSparams

lpmTeXParams = defaultLPMparams

tableWidth :: Double --in cm
tableWidth = 10.5

verboseDDDescription :: Bool
verboseDDDescription = True

--TeX Document Parameter Defaults (can be modified to affect all documents OR
  -- you can create your own parameter function and replace the one above.
defaultSRSparams :: [DocParams]
defaultSRSparams = [
  DocClass  [] "article",
  UsePackages ["booktabs","longtable"]
  ]

defaultLPMparams :: [DocParams]
defaultLPMparams = [
  DocClass "article" "cweb-hy",
  UsePackages ["xr"],
  ExDoc "L-" "hghc_SRS"
  ]
  
-- datadefnFields :: [Field]
-- datadefnFields = [Symbol, SIU, Equation, Description]

  --column width for data definitions (fraction of textwidth)
colAwidth, colBwidth :: Double
colAwidth = 0.2
colBwidth = 0.73
