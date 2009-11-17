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
    { backupDir = "_some_bogus_unused_value_"
    }

readConfig :: IO Config
readConfig = read <$> readFile ".hackup/config"

writeConfig :: Config -> IO ()
writeConfig = writeFile ".hackup/config" . (++"\n") . show
