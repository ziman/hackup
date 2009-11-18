module Plugin.Add (run) where

import Utils
import Config
import Filelist
import qualified FileHash

import Data.List
import System.Posix.Files
import Control.Applicative
import qualified Data.Map as M

run :: Config -> [String] -> IO ()
run _ [] = putStrLn "usage: hackup add <file> [<file> <file> ..∘]"

run config args = do
    entries <- readEntries config
    let oldEntries = M.fromList $ map (\e -> (name e, e)) entries
        oldCount   = M.size oldEntries
    new <- mapM addFile args
    let newEntries = M.fromList $ map (\e -> (name e, e)) new
    let finalEntries = newEntries `M.union` oldEntries
        finalCount   = M.size newEntries
    writeEntries config $ M.elems finalEntries
    putStrLn $ show (finalCount - oldCount) ++ " file(s) added."

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

