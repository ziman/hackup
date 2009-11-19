module Plugin.Burn (run) where

import Filelist
import Config
import Utils

import Control.Applicative
import System.Process
import System.FilePath
import System.IO
import Data.List

burnCommand :: String
burnCommand = intercalate " -"
    [ "growisofs", "Z /dev/hda", "dry-run", "speed=4", "dvd-compat"
    , "A hackup", "input-charset utf8", "J", "l", "m .hackup"
    , "m '*~'", "m '.*.swp'", "path-list -", "r", "v", "graft-points"
    ]

-- Input format: [(LocalFile, DvdFile)]
formatList :: [(FilePath,FilePath)] -> String
formatList = concatMap (\(from,to) -> to ++ "=" ++ from ++ "\n")

calcPath :: Entry -> (FilePath,FilePath)
calcPath e = (name e, name e)

recode :: Entry -> String
recode e = name e ++ "=" ++ name e

burnPart :: Config -> String -> String -> IO ()
burnPart config pname partno = do
    putStrLn $ "Burning part " ++ partno
    putStrLn burnCommand
    (Just sin, _, _, p) <- createProcess (shell $ burnCommand){ std_in = CreatePipe }
    hPutStr sin . unlines . map recode =<< readEntriesLazily partPath
    hClose sin
    waitForProcess p
    return ()
  where
    partPath = fRoot config ++ "/plans/" ++ pname ++ "/parts/" ++ partno

run :: Config -> [String] -> IO ()
run config ("first":pname:args) = resetBurner config pname "000000" >> burnNext config pname args
run config ("next":pname:args)  = burnNext config pname args
run config _ = putStrLn "Usage: hackup burn (first <plan-name>|next <plan-name>)"

resetBurner :: Config -> String -> String -> IO ()
resetBurner config pname value = writeFile (fRoot config ++ "/plans/" ++ pname ++ "/burn") value

burnNext :: Config -> String -> [String] -> IO ()
burnNext config pname args = do
    current <- strictRead (planPath ++ "/burn")
    resetBurner config pname (next current)
    burnPart config pname current
  where
    planPath = fRoot config ++ "/plans/" ++ pname

next :: String -> String
next = fst . foldr next' ("", True)

next' :: Char -> (String, Bool) -> (String, Bool)
next' c (rest,flip)
    | flip = case c of
        '9' -> ('0':rest, True)
        x   -> (succ x:rest, False)
    | otherwise = (c:rest, False)
