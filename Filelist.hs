module Filelist
    ( readEntries, readEntriesLazily
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
    , inode :: FileID
    , size  :: FileOffset
    , date  :: EpochTime
    , hash  :: Hash
    }
    deriving (Show, Read)

instance NFData Entry where
    rnf (Entry n i s d h) = rnf n `seq` i `seq` s `seq` d `seq` rnf h

readEntries :: FilePath -> IO [Entry]
readEntries fname = do
    f <- openFile fname ReadMode
    stuff <- decompress <$> BS.hGetContents f
    let entries = map (read . BS.unpack) . BS.split '\n' $ stuff
    rnf entries `seq` hClose f
    return entries

readEntriesLazily :: FilePath -> IO [Entry]
readEntriesLazily fname =
    map (read . BS.unpack) . BS.split '\n' . decompress
    <$> BS.readFile fname

writeEntries :: FilePath -> [Entry] -> IO ()
writeEntries fname =
      BS.writeFile fname
    . compress . BS.intercalate nl . map (BS.pack . show)
  where
    nl = BS.pack "\n"
