module Plugin.Plan (run) where

import Filelist
import FileHash
import Config
import Utils

import System.Directory
import Control.Applicative

run :: Config -> [String] -> IO ()
run config ["create", pname] = createPlan config pname
run config ["delete", pname] = deletePlan config pname
run config ["list"] = listPlans config
run config _ = putStrLn "Usage: hackup plan (create <name>|delete <name>|list)"

createPlan :: Config -> String -> IO ()
createPlan config pname = do
    let planPath = fRoot config ++ "/plans/" ++ pname
    createDirectoryIfMissing True planPath
    writeFile (planPath ++ "/dvd0001") "__FOO__\n"
    putStrLn "Plan created."

deletePlan :: Config -> String -> IO ()
deletePlan config pname = do
    let planPath = fRoot config ++ "/plans/" ++ pname
    removeDirectoryRecursive planPath
    putStrLn "Plan deleted."

listPlans :: Config -> IO ()
listPlans config = do
    plans <- saneDirectoryContents (fRoot config ++ "/plans")
    sizes <- mapM (getSize . ((fRoot config ++ "/plans/") ++)) plans
    if null plans
        then putStrLn "No plans."
        else mapM_ printPlan $ zip plans sizes

getSize :: String -> IO Int
getSize ppath = length <$> saneDirectoryContents ppath

printPlan :: (String, Int) -> IO ()
printPlan (pname, psize) = putStrLn $ pname ++ "\t: " ++ show psize ++ " part(s)"
