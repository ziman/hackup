module Plugin.Status (run) where

import Filelist
import Config

run :: [String] -> IO ()
run _ = do
    config <- readConfig
    entries <- readEntries config
    putStrLn "Entries: "
    print entries
