module Filelist
    ( readEntries
    , writeEntries
    , Entry (..)
    )
    where

import Config
import FileHash

import qualified Data.ByteString.Lazy.Char8 as BS
import Codec.Compression.GZip
import System.Posix.Types
import Control.Applicative
import Data.Word
import Data.Char
import Control.Parallel.Strategies
import System.IO

data Entry = Entry
    { name  :: String
    , size  :: FileOffset
    , date  :: EpochTime
    , hash  :: Hash
    }
    deriving (Show, Read)

instance NFData Entry where
    rnf (Entry n s d h) = rnf n `seq` s `seq` d `seq` rnf h

readEntries :: Config -> IO [Entry]
readEntries config = do
    f <- openFile (fEntries config) ReadMode
    stuff <- decompress <$> BS.hGetContents f
    let entries = map (read . BS.unpack) . BS.split '\n' $ stuff
    rnf entries `seq` hClose f
    return entries

readEntriesLazily :: Config -> IO [Entry]
readEntriesLazily config =
    map (read . BS.unpack) . BS.split '\n' . decompress
    <$> BS.readFile (fEntries config)

writeEntries :: Config -> [Entry] -> IO ()
writeEntries config =
      BS.writeFile (fEntries config)
    . compress . BS.intercalate nl . map (BS.pack . show)
  where
    nl = BS.pack "\n"
