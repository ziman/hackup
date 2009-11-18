module Utils
    ( strictly
    , saneDirectoryContents
    , strictRead
    )
    where

import Control.Applicative
import Control.Parallel.Strategies
import System.Directory
import System.IO

strictRead :: FilePath -> IO String
strictRead fname = do
    f <- openFile fname ReadMode
    stuff <- hGetContents f
    rnf stuff `seq` hClose f
    return stuff

strictly :: NFData a => a -> a
strictly x = rnf x `seq` x

saneDirectoryContents :: FilePath -> IO [FilePath]
saneDirectoryContents path = clean `fmap` getDirectoryContents path
  where
    clean = filter (`notElem` [".","..",".hackup"])
