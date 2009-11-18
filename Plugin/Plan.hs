module Plugin.Plan (run) where

import Filelist
import FileHash
import Config

import System.Directory

run :: Config -> [String] -> IO ()
run config ["create", pname] = createPlan config pname
run config _ = putStrLn "Usage: hackup plan (create <name>|delete <name>|list)"

createPlan :: Config -> String -> IO ()
createPlan config pname = do
    let planPath = fRoot config ++ "/plans/" ++ pname
    createDirectoryIfMissing True planPath
    writeFile (planPath ++ "/dvd0001") "__FOO__"
