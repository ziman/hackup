import Config
import qualified Plugin.Init
import qualified Plugin.Help
import qualified Plugin.Deinit
import qualified Plugin.Status
import qualified Plugin.Add
import qualified Plugin.Debug

import Control.Monad
import Data.List
import System
import System.IO

commands =
    [ ("init",      Plugin.Init.run)
    , ("deinit",    wrap Plugin.Deinit.run)
    , ("status",    wrap Plugin.Status.run)
    , ("debug",     wrap Plugin.Debug.run)
    , ("add",       wrap Plugin.Add.run)
    , ("help",      Plugin.Help.run)
    ]

wrap :: (Config -> [String] -> IO ()) -> [String] -> IO ()
wrap f args = flip f args =<< readConfig

main :: IO ()
main = do
    args <- getArgs
    let (cmd:cmdargs) = if null args then ["help"] else args
    case lookup cmd commands of
        Nothing -> hPutStrLn stderr $ "Unknown command: " ++ cmd
        Just f  -> f cmdargs
