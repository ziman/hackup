module Plugin.Plan (run) where

import Filelist
import FileHash
import Config
import Utils

import System.Directory
import Control.Applicative
import Data.Word

data PlanConfig = PlanConfig
        { partSizeLimit :: Word64
        }
        deriving (Read, Show)

run :: Config -> [String] -> IO ()
run config ["create", "",""] = run config []
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
    let planPath = fRoot config ++ "/plans/" ++ pname
        plancfg = defaultPlanConfig
    createDirectoryIfMissing True (planPath ++ "/parts")
    writeFile (planPath ++ "/config") (show plancfg)
    putStrLn "Plan created."

deletePlan :: Config -> String -> IO ()
deletePlan config pname = do
    let planPath = fRoot config ++ "/plans/" ++ pname
    removeDirectoryRecursive planPath
    putStrLn "Plan deleted."

listPlans :: Config -> IO ()
listPlans config = do
    plans <- saneDirectoryContents (fRoot config ++ "/plans")
    sizes <- mapM (getSize . (++"/parts") . ((fRoot config ++ "/plans/") ++)) plans
    if null plans
        then putStrLn "No plans."
        else mapM_ printPlan $ zip plans sizes

getSize :: String -> IO Int
getSize ppath = length <$> saneDirectoryContents ppath

printPlan :: (String, Int) -> IO ()
printPlan (pname, psize) = putStrLn $ pname ++ "\t: " ++ show psize ++ " part(s)"
