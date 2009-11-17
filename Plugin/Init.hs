module Plugin.Init (run) where

import Config

import System.Directory

run :: [String] -> IO ()
run args = do
    createDirectory ".hackup"
    writeConfig initialConfig
    putStrLn "Hackup initialized."
