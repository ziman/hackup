import Config
import qualified Plugin.Init
import qualified Plugin.Help

import Control.Monad
import Data.List
import System
import System.IO

commands =
    [ ("init", Plugin.Init.run)
    , ("help", Plugin.Help.run)
    ]

main :: IO ()
main = do
    args <- getArgs
    let (cmd:cmdargs) = if null args then ["help"] else args
    case lookup cmd commands of
        Nothing -> hPutStrLn stderr $ "Unknown command: " ++ cmd
        Just f  -> f cmdargs
