module Plugin.Plan (run) where

import Filelist
import FileHash
import Config

run :: Config -> [String] -> IO ()
run config args = putStrLn "Plan stub."
