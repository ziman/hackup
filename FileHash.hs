module FileHash (Hash, hash, hashFile) where

import qualified Data.ByteString.Lazy as BS
import Data.Word
import Data.Function
import Control.Parallel.Strategies

newtype Hash = Hash Word32 deriving (Read, Show, Eq, Ord)

instance NFData Hash where
    rnf (Hash x) = x `seq` ()

hash :: BS.ByteString -> Hash
hash = Hash . BS.foldl (\s c -> 3*s + fromIntegral c) 0xF0EC3D45

hashFile :: String -> IO Hash
hashFile fn = hash `fmap` BS.readFile fn
