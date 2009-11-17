module Plugin.Add (run) where

import Utils
import Config
import Filelist
import qualified FileHash

import Data.List
import System.Posix.Files
import Control.Applicative

run :: Config -> [String] -> IO ()
run _ [] = putStrLn "usage: hackup add <file> [<file> <file> ..∘]"

run config args = do
    entries <- strictly <$> readEntries config
    print entries
    new <- mapM addFile args
    writeEntries config $ new ++ filter ((`notElem` args) . name) entries

addFile :: String -> IO Entry
addFile fn = do
    status   <- getFileStatus fn
    fileHash <- FileHash.hashFile fn
    return Entry
        { name = fn
        , size = fileSize status
        , date = modificationTime status
        , hash = fileHash
        }

