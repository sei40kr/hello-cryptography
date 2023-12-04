module Lib (feistelEncrypt, feistelDecrypt) where

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
