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

data Entry = Entry
    { name  :: String
    , size  :: FileOffset
    , date  :: EpochTime
    , hash  :: Hash
    }
    deriving (Show, Read)

readEntries :: Config -> IO [Entry]
readEntries config = map (read . BS.unpack) . BS.split '\n'
    . decompress <$> BS.readFile (fEntries config)

writeEntries :: Config -> [Entry] -> IO ()
writeEntries config =
      BS.writeFile (fEntries config)
    . compress . BS.intercalate nl . map (BS.pack . show)
  where
    nl = BS.pack "\n"
