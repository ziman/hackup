module Plugin.Deinit (run) where

import Config

import System.Directory

run :: [String] -> IO ()
run args = deinit args =<< readConfig

deinit ["--really"] config = do
    removeDirectoryRecursive (fRoot config)
    putStrLn "Hackup deinitialized."

deinit _ _ = putStr $ unlines
    [ "WARNING: This operation will irreversibly delete the .hackup directory."
    , "If you are sure you want this, use `hackup deinit --really'."
    ]    
