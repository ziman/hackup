module Plugin.Burn (run) where

import Filelist
import Config
import Utils

import Control.Applicative

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
    putStrLn $ "Burning " ++ current
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
