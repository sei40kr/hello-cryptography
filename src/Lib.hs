module Lib (cbcDecrypt, cbcEncrypt, ecbDecrypt, ecbEncrypt, feistelDecrypt, feistelEncrypt) where

import Data.Bits (xor)
import Data.Char (chr, ord)

xorStrings :: String -> String -> String
xorStrings [] [] = []
xorStrings [] _ = error "xorStrings: length mismatch"
xorStrings _ [] = error "xorStrings: length mismatch"
xorStrings (x : xs) (y : ys) = chr (ord x `xor` ord y) : xorStrings xs ys

-- Encrypt a block using the given keys and round function.
feistelEncrypt :: [String] -> (String -> String -> String) -> String -> String
feistelEncrypt keys roundFn block = right' ++ left'
  where
    (left, right) = splitAt (length block `div` 2) block
    f (l, r) key = (r, xorStrings l (roundFn r key))
    (left', right') = foldl f (left, right) keys

-- Decrypt a block using the given keys and round function.
feistelDecrypt :: [String] -> (String -> String -> String) -> String -> String
feistelDecrypt keys = feistelEncrypt (reverse keys)

ecbEncrypt :: [String] -> (String -> String -> String) -> [String] -> String
ecbEncrypt keys roundFn = concatMap $ feistelEncrypt keys roundFn

ecbDecrypt :: [String] -> (String -> String -> String) -> [String] -> String
ecbDecrypt keys roundFn = concatMap $ feistelDecrypt keys roundFn

cbcEncrypt :: [String] -> (String -> String -> String) -> String -> [String] -> String
cbcEncrypt _ _ _ [] = []
cbcEncrypt keys roundFn iv (block : blocks) = encryptedBlock ++ cbcEncrypt keys roundFn encryptedBlock blocks
  where
    encryptedBlock = feistelEncrypt keys roundFn $ xorStrings iv block

cbcDecrypt :: [String] -> (String -> String -> String) -> String -> [String] -> String
cbcDecrypt _ _ _ [] = []
cbcDecrypt keys roundFn iv (block : blocks) = decryptedBlock ++ cbcDecrypt keys roundFn block blocks
  where
    decryptedBlock = feistelDecrypt keys roundFn $ xorStrings iv block
