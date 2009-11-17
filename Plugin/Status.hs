module Plugin.Status (run) where

import Filelist
import Config

run :: Config -> [String] -> IO ()
run config _ = do
    entries <- readEntries config
    putStrLn "Entries: "
    print entries
    putStrLn "Config: "
    print config
