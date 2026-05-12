module Sesh.Ipc (
  ClientFrame (..),
  decodeClientFrames,
  decodeServerFrames,
  encodeClientFrame,
  encodeServerFrame,
  ServerFrame (..),
) where

import Data.Bits (shiftL, shiftR, (.|.))
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import Data.Word (Word32, Word8)

data ClientFrame
  = ClientInit (Int, Int)
  | ClientInput BS.ByteString
  | ClientResize (Int, Int)
  | ClientDetach
  deriving (Eq, Show)

data ServerFrame
  = ServerOutput BS.ByteString
  deriving (Eq, Show)

encodeClientFrame :: ClientFrame -> BS.ByteString
encodeClientFrame frame =
  encodeFrame tag payload
  where
    (tag, payload) = case frame of
      ClientInit dimensions -> (1, encodeDimensions dimensions)
      ClientInput bytes -> (2, bytes)
      ClientResize dimensions -> (3, encodeDimensions dimensions)
      ClientDetach -> (4, BS.empty)

encodeServerFrame :: ServerFrame -> BS.ByteString
encodeServerFrame frame =
  encodeFrame tag payload
  where
    (tag, payload) = case frame of
      ServerOutput bytes -> (1, bytes)

decodeClientFrames :: BS.ByteString -> ([ClientFrame], BS.ByteString)
decodeClientFrames = decodeFrames decodeClientPayload

decodeServerFrames :: BS.ByteString -> ([ServerFrame], BS.ByteString)
decodeServerFrames = decodeFrames decodeServerPayload

decodeFrames :: (Word8 -> BS.ByteString -> Maybe frame) -> BS.ByteString -> ([frame], BS.ByteString)
decodeFrames decodePayload = go []
  where
    go frames input
      | BS.length input < headerLength = (reverse frames, input)
      | frameLength > maxFrameLength = (reverse frames, BS.empty)
      | BS.length input < totalLength = (reverse frames, input)
      | otherwise =
          let payload = BS.take frameLength (BS.drop headerLength input)
              rest = BS.drop totalLength input
           in case decodePayload tag payload of
                Nothing -> go frames rest
                Just frame -> go (frame : frames) rest
      where
        tag = BS.index input 0
        frameLength = fromIntegral (decodeLength (BS.take 4 (BS.drop 1 input)))
        totalLength = headerLength + frameLength

headerLength :: Int
headerLength = 5

maxFrameLength :: Int
maxFrameLength = 1024 * 1024

encodeFrame :: Word8 -> BS.ByteString -> BS.ByteString
encodeFrame tag payload =
  BS.cons tag (encodeLength (fromIntegral (BS.length payload)) <> payload)

encodeDimensions :: (Int, Int) -> BS.ByteString
encodeDimensions (widthValue, heightValue) = BS8.pack (show widthValue <> " " <> show heightValue)

decodeClientPayload :: Word8 -> BS.ByteString -> Maybe ClientFrame
decodeClientPayload tag payload = case tag of
  1 -> ClientInit <$> decodeDimensions payload
  2 -> Just (ClientInput payload)
  3 -> ClientResize <$> decodeDimensions payload
  4 -> Just ClientDetach
  _ -> Nothing

decodeServerPayload :: Word8 -> BS.ByteString -> Maybe ServerFrame
decodeServerPayload tag payload = case tag of
  1 -> Just (ServerOutput payload)
  _ -> Nothing

decodeDimensions :: BS.ByteString -> Maybe (Int, Int)
decodeDimensions payload = case words (BS8.unpack payload) of
  [widthText, heightText] -> case (reads widthText, reads heightText) of
    ([(widthValue, "")], [(heightValue, "")]) -> Just (widthValue, heightValue)
    _ -> Nothing
  _ -> Nothing

encodeLength :: Word32 -> BS.ByteString
encodeLength value =
  BS.pack
    [ fromIntegral (value `shiftR` 24),
      fromIntegral (value `shiftR` 16),
      fromIntegral (value `shiftR` 8),
      fromIntegral value
    ]

decodeLength :: BS.ByteString -> Word32
decodeLength bytes =
  foldl
    (\acc byte -> (acc `shiftL` 8) .|. fromIntegral byte)
    0
    (BS.unpack bytes)
