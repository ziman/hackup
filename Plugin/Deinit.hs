module Plugin.Deinit (run) where

import Config

import System.Directory

run :: [String] -> IO ()
run ["--really"] = do
    removeDirectoryRecursive ".hackup"
    putStrLn "Hackup deinitialized."

run _ = putStr $ unlines
    [ "WARNING: This operation will irreversibly delete the .hackup directory."
    , "If you are sure you want this, use `hackup deinit --really'."
    ]    
