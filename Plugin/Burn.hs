module Plugin.Burn (run) where

import Filelist
import Config
import Utils

run :: Config -> [String] -> IO ()
run config ("first":args) = resetBurner config >> burnNext config args
run config ("next":args)  = burnNext config args
run config _ = putStrLn "Usage: hackup burn (first|next)"

resetBurner :: Config -> IO ()
resetBurner config = return ()

burnNext :: Config -> [String] -> IO ()
burnNext config args = return ()
