module Plugin.Plan (run) where

import Filelist
import FileHash
import Config
import Utils
import Planner

import System.Directory
import Control.Applicative
import Data.Word
import Data.Char
import Control.Monad

data PlanConfig = PlanConfig
        { partSizeLimit :: Word64
        }
        deriving (Read, Show)

data PlanInfo = PlanInfo
        { planConfig :: PlanConfig
        , partCount  :: Int
        , planName   :: String
        , planRoot   :: FilePath
        }

run :: Config -> [String] -> IO ()
run config ["create", "", _] = run config []
run config ["create", pname,psize] = createPlan config pname psize
run config ["delete", pname] = deletePlan config pname
run config ["list"] = listPlans config
run config _ = putStrLn "Usage: hackup plan (create <name> <partsize>|delete <name>|list)"

defaultPlanConfig :: PlanConfig
defaultPlanConfig = PlanConfig
    { partSizeLimit = 256 * 1024 * 1024
    }

createPlan :: Config -> String -> String -> IO ()
createPlan config pname psize = do
    sizeLimit <- case parseSize psize of
        Just limit -> return limit
        Nothing    -> ioError . userError $ "Invalid size: " ++ psize
    let plancfg = defaultPlanConfig { partSizeLimit = sizeLimit }
    createDirectoryIfMissing True (planPath ++ "/parts")
    writeFile (planPath ++ "/config") (show plancfg)
    putStrLn "Plan created."
  where
    planPath  = fRoot config ++ "/plans/" ++ pname

parseSize :: String -> Maybe Word64
parseSize [] = Nothing
parseSize size
    | all isDigit size = Just $ read size
    | otherwise = parseNumber (init size) <*> parseSuffix (toUpper $ last size)
  where
    parseNumber nr = if all isDigit nr then Just (read nr *) else Nothing
    parseSuffix 'G' = Just $ 1024 ^ 3
    parseSuffix 'M' = Just $ 1024 ^ 2
    parseSuffix 'K' = Just $ 1024 ^ 1
    parseSuffix _   = Nothing

deletePlan :: Config -> String -> IO ()
deletePlan config pname = do
    removeDirectoryRecursive planPath
    putStrLn "Plan deleted."
  where
    planPath = fRoot config ++ "/plans/" ++ pname

listPlans :: Config -> IO ()
listPlans config = do
    info <- mapM (getPlanInfo config) =<< saneDirectoryContents (fRoot config ++ "/plans")
    if null info
        then putStrLn "No plans."
        else mapM_ printPlan info

getPlanInfo :: Config -> String -> IO PlanInfo
getPlanInfo config pname = do
    count  <- getSize (planPath ++ "/parts") 
    config <- read <$> readFile (planPath ++ "/config")
    return $ PlanInfo
        { planConfig = config
        , partCount  = count
        , planName   = pname
        , planRoot   = planPath
        }
  where
    planPath  = fRoot config ++ "/plans/" ++ pname

getSize :: String -> IO Int
getSize ppath = length <$> saneDirectoryContents ppath

printPlan :: PlanInfo -> IO ()
printPlan pinfo = putStrLn $ concat 
    [ planName pinfo, "\t: ",show $ partCount pinfo, " part(s) limited to "
    , scale (partSizeLimit $ planConfig pinfo)
    ]

scale :: Word64 -> String
scale x
    | x < 10*1024^1 = scale' x 0 "B"
    | x < 10*1024^2 = scale' x 1 "k"
    | x < 10*1024^3 = scale' x 2 "M"
    | x < 10*1024^4 = scale' x 3 "G"
    | otherwise     = scale' x 4 "T"
  where
    scale' x order suffix = show (x `div` 1024^order) ++ suffix
