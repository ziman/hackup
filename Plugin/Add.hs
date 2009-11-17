module Plugin.Add (run) where

import Config
import Filelist
import qualified FileHash

import Data.List
import System.Posix.Files

run :: Config -> [String] -> IO ()
run _ [] = putStrLn "usage: hackup add <file> [<file> <file> ..∘]"

run config args = do
    entries <- readEntries config
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
