module Plugin.Status (run) where

import Filelist
import qualified FileHash
import Config
import System.Posix.Files

data Status = Vanilla | Changed deriving (Show, Eq)

inspect :: Entry -> IO Status
inspect entry = do
    fstat <- getFileStatus (name entry)
    if (fileSize fstat /= size entry)
        then return Changed
        else if (modificationTime fstat <= date entry)
            then return Vanilla
            else do
                newHash <- FileHash.hashFile (name entry)
                if (newHash /= hash entry)
                    then return Changed
                    else return Vanilla

run :: Config -> [String] -> IO ()
run config _ = do
    entries <- readEntriesLazily (fEntries config)
    statuses <- mapM inspect entries
    let pairs = zip statuses entries
        changed = filter ((/= Vanilla) . fst) pairs
    if null changed
        then putStrLn "No changes, clean."
        else mapM_ (\(s,e) -> putStrLn $ ' ':' ':schar s : "\t" ++ name e) changed

schar Changed = 'M'
schar _       = '?'
