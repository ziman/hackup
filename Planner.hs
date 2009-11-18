module Planner
    ( computePlan
    )
    where

import Filelist
import Config
import Utils

import Data.Word
import Data.List

computePlan :: Word64 -> [Entry] -> [[Entry]]
computePlan limit = unfoldr (phi limit)

phi limit [] = Nothing
phi limit xs = Just (map fst part, map fst rest)
  where
    (part,rest) = break ((> limit) . snd) $ zip xs (tail sums)
    sums = scanl (+) 0 $ map (fromIntegral . size) xs
