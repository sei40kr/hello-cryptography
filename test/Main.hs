import Lib
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "chunksOf" $ do
    it "when empty string is given, returns empty list" $ do
      chunksOf 1 "" `shouldBe` ([] :: [String])
    it "when string is given, returns list of chunks" $ do
      chunksOf 2 "123456" `shouldBe` ["12", "34", "56"]
    it "when string is given and chunk size is less than string length, returns list with last chunk padded with null characters" $ do
      chunksOf 5 "123456" `shouldBe` ["12345", "6\0\0\0\0"]
    it "when string is given and chunk size is equal to string length, returns list with one chunk" $ do
      chunksOf 6 "123456" `shouldBe` ["123456"]
    it "when string is given and chunk size is greater than string length, returns list with one chunk padded with null characters" $ do
      chunksOf 7 "123456" `shouldBe` ["123456\0"]
