module Utils
    ( strictly
    )
    where

import Control.Parallel.Strategies

strictly :: NFData a => a -> a
strictly x = x `using` rnf
