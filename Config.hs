module Config
    ( Config (..)
    , readConfig
    , writeConfig
    , initialConfig
    )
    where

import Control.Applicative
import Control.Parallel.Strategies

data Config = Config
    { fEntries :: String
    , fRoot    :: String
    }
    deriving (Read, Show)

initialConfig :: Config
initialConfig = Config
    { fEntries = ".hackup/entries"
    , fRoot    = ".hackup"
    }

readConfig :: IO Config
readConfig = read <$> readFile ".hackup/config"

writeConfig :: Config -> IO ()
writeConfig = writeFile ".hackup/config" . (++"\n") . show
