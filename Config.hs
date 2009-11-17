module Config
    ( Config (..)
    , readConfig
    )
    where

import Control.Applicative

data Config = Config
    { backupDir :: String
    }
    deriving (Read, Show)

readConfig :: IO Config
readConfig = read <$> readFile ".hackup/config"
