module Config
    ( Config (..)
    , readConfig
    , writeConfig
    , initialConfig
    )
    where

import Control.Applicative

data Config = Config
    { backupDir :: String
    }
    deriving (Read, Show)

initialConfig :: Config
initialConfig = Config
    { backupDir = ""
    }

readConfig :: IO Config
readConfig = read <$> readFile ".hackup/config"

writeConfig :: Config -> IO ()
writeConfig = writeFile ".hackup/config" . show
