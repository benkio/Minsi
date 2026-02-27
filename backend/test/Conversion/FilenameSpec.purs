module Test.Conversion.FilenameSpec where

import Prelude

import Conversion.Filename (buildUploadedFilename, extractBaseName, extractFileExt)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "extractFileExt" do
    it "extracts .mp4 extension" $
      extractFileExt "video.mp4" `shouldEqual` ".mp4"

    it "extracts .txt extension" $
      extractFileExt "file.txt" `shouldEqual` ".txt"

    it "handles multiple dots by taking from the first dot" $
      extractFileExt "my.file.tar.gz" `shouldEqual` ".file.tar.gz"

    it "returns empty string when no extension" $
      extractFileExt "noext" `shouldEqual` ""

  describe "extractBaseName" do
    it "extracts base name before extension" $
      extractBaseName "video.mp4" `shouldEqual` "video"

    it "extracts base name with multiple dots" $
      extractBaseName "my.file.tar.gz" `shouldEqual` "my"

    it "returns whole string when no extension" $
      extractBaseName "noext" `shouldEqual` "noext"

  describe "buildUploadedFilename" do
    it "builds uploaded filename with extension" $
      buildUploadedFilename "video" ".mp4" `shouldEqual` "video_uploaded.mp4"

    it "builds uploaded filename without extension" $
      buildUploadedFilename "file" "" `shouldEqual` "file_uploaded"
