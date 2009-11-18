module Plugin.Add (run) where

import Utils
import Config
import Filelist
import qualified FileHash

import Data.List
import System.Posix.Files
import System.Directory
import Control.Applicative
import qualified Data.Map as M

data Classification = Regular | Directory | Symlink | Other

run :: Config -> [String] -> IO ()
run _ [] = putStrLn "usage: hackup add <file> [<file> <file> ..∘]"

run config args = do
    entries <- readEntries config
    let oldEntries = M.fromList $ map (\e -> (inode e, e)) entries
        oldCount   = M.size oldEntries
    new <- concat <$> mapM addEntry args
    let newEntries = M.fromList $ map (\e -> (inode e, e)) new
    let finalEntries = newEntries `M.union` oldEntries
        finalCount   = M.size finalEntries
    writeEntries config $ M.elems finalEntries
    putStrLn $ show (finalCount - oldCount) ++ " file(s) added."

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
        Symlink   -> (putStrLn $ "Ignoring symlink: " ++ fn) >> return []
        Other     -> (putStrLn $ "Not a regular file: " ++ fn) >> return []

addDir :: String -> IO [Entry]
addDir fn = concat <$> (mapM addEntry . map (prefix++) . clean =<< getDirectoryContents fn)
  where
    clean = filter (`notElem` [".",".."])
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

