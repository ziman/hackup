module Utils
    ( strictly
    , saneDirectoryContents
    )
    where

import Control.Parallel.Strategies
import System.Directory

strictly :: NFData a => a -> a
strictly x = x `using` rnf

saneDirectoryContents :: FilePath -> IO [FilePath]
saneDirectoryContents path = clean `fmap` getDirectoryContents path
  where
    clean = filter (`notElem` [".","..",".hackup"])
