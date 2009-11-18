module Plugin.Add (run) where

import Utils
import Config
import Filelist
import qualified FileHash

import Control.Arrow
import Data.List
import System.Posix.Files
import System.Directory
import Control.Applicative
import Control.Monad
import qualified Data.Map as M

data Classification = Regular | Directory | Symlink | Other

run :: Config -> [String] -> IO ()
run _ [] = putStrLn "usage: hackup add <file> [<file> <file> ..∘]"

run config args = do
    entries <- readEntries (fEntries config)
    new <- concat <$> mapM (addEntry <=< canonicalizePath) args
    let oldEntries   = setify entries
        oldCount     = M.size oldEntries
        newEntries   = setify new
        finalEntries = newEntries `M.union` oldEntries
        finalCount   = M.size finalEntries
    writeEntries (fEntries config) $ M.elems finalEntries
    putStrLn $ show (finalCount - oldCount) ++ " new file(s) added."
  where
    setify = M.fromList . map (name &&& id)

classify status = 
    if isRegularFile status then Regular
    else if isDirectory status then Directory
    else if isSymbolicLink status then Symlink
    else Other

addEntry :: String -> IO [Entry]
addEntry fn = do
    status <- getFileStatus fn
    case classify status of
        Regular   -> (:[]) <$> addFile fn status
        Directory -> addDir fn
        Symlink   -> addEntry =<< readSymbolicLink fn
        Other     -> (putStrLn $ "Not a regular file: " ++ fn) >> return []

addDir :: String -> IO [Entry]
addDir fn = concat <$> (mapM addEntry . map (prefix++) =<< saneDirectoryContents fn)
  where
    prefix = fn ++ "/"

addFile :: String -> FileStatus -> IO Entry
addFile fn status = do
    fileHash <- FileHash.hashFile fn
    return Entry
        { name  = fn
        , size  = fileSize status
        , date  = modificationTime status
        , hash  = fileHash
        , inode = fileID status
        }

