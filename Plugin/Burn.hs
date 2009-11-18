module Plugin.Burn (run) where

import Filelist
import Config
import Utils

run :: Config -> [String] -> IO ()
run config args = putStrLn "Burn stub."
