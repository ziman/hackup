module Plugin.Init (run) where

import Config
import Filelist

import System.Directory

run :: [String] -> IO ()
run args = do
    createDirectory ".hackup"
    let config = initialConfig
    writeConfig config
    writeEntries (fEntries config) []
    putStrLn "Hackup initialized."
