module Plugin.Deinit (run) where

import Config

import System.Directory

run config ["--really"] = do
    removeDirectoryRecursive (fRoot config)
    putStrLn "Hackup deinitialized."

run _ _ = putStr $ unlines
    [ "WARNING: This operation will irreversibly delete the .hackup directory."
    , "If you are sure you want this, use `hackup deinit --really'."
    ]    
