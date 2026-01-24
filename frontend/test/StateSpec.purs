module Test.StateSpec where

import Prelude
import Data.Maybe (Maybe(..), fromJust)
import Partial.Unsafe (unsafePartial)
import Model.State.State (State(..), DurationRange(..), Subtitle(..), Font(..), Color(..), Position(..), WURL(..))
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Function.Uncurried (Fn1, runFn1)
import Data.URL (fromString)
import Yoga.JSON (writeJSON)
import Data.Time.Duration (Milliseconds(..))
import Foreign (Foreign)
import Foreign.Object (Object, lookup)
import Foreign as Foreign
import Effect.Exception (error, throwException)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Effect (Effect)
import Data.Array (index, length)

readForeignNumber :: Foreign -> Effect Number
readForeignNumber f = either (throwException <<< error <<< show) pure (runExcept (Foreign.readNumber f))

readForeignString :: Foreign -> Effect String
readForeignString f = either (throwException <<< error <<< show) pure (runExcept (Foreign.readString f))

readForeignBoolean :: Foreign -> Effect Boolean
readForeignBoolean f = either (throwException <<< error <<< show) pure (runExcept (Foreign.readBoolean f))

readForeignInt :: Foreign -> Effect Int
readForeignInt f = either (throwException <<< error <<< show) pure (runExcept (Foreign.readInt f))

readForeignArray :: Foreign -> Effect (Array Foreign)
readForeignArray f = either (throwException <<< error <<< show) pure (runExcept (Foreign.readArray f))

foreign import parseJSONImpl :: Fn1 String Foreign

parseJSON :: String -> Foreign
parseJSON = runFn1 parseJSONImpl

spec :: Spec Unit
spec = do
  describe "State JSON encoding" do
    it "should encode State to JSON properly" $ liftEffect $ do
      -- Create a sample State
      let
        youtubeUrl = WURL (unsafePartial fromJust (fromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
        cutVideo = DurationRange { start: Milliseconds 0.0, end: Milliseconds 100.0 }
        filename = "output.mp4"
        reverseLoop = false
        artist = "Test Artist"
        title = "Test Title"
        subtitle =
          Subtitle
            { videoPosition: DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
            , value: "Test subtitle"
            , font: Impact
            , size: 24
            , color: White
            , screenPosition: Top
            }
        state =
          State
            { cutVideo: cutVideo
            , youtubeUrl: youtubeUrl
            , filename: filename
            , reverseLoop: reverseLoop
            , artist: artist
            , title: title
            , subtitles: [ subtitle ]
            }

      -- Encode to JSON
      let jsonString = writeJSON state

      -- Parse JSON string to Foreign
      let json = parseJSON jsonString

      -- Verify the JSON structure
      let jsonObj = Foreign.unsafeFromForeign json :: Object Foreign

      -- Check cutVideo
      cutVideoJson <- case lookup "cutVideo" jsonObj of
        Just cv -> pure cv
        Nothing -> liftEffect $ throwException $ error "cutVideo field missing"
      let cutVideoObj = Foreign.unsafeFromForeign cutVideoJson :: Object Foreign
      startValue <- case lookup "start" cutVideoObj of
        Just s -> liftEffect $ readForeignNumber s
        Nothing -> liftEffect $ throwException $ error "start field missing in cutVideo"
      endValue <- case lookup "end" cutVideoObj of
        Just e -> liftEffect $ readForeignNumber e
        Nothing -> liftEffect $ throwException $ error "end field missing in cutVideo"
      startValue `shouldEqual` 0.0
      endValue `shouldEqual` 100.0

      -- Check youtubeUrl
      youtubeUrlValue <- case lookup "youtubeUrl" jsonObj of
        Just yu -> liftEffect $ readForeignString yu
        Nothing -> liftEffect $ throwException $ error "youtubeUrl field missing"
      youtubeUrlValue `shouldEqual` "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

      -- Check filename
      filenameValue <- case lookup "filename" jsonObj of
        Just f -> liftEffect $ readForeignString f
        Nothing -> liftEffect $ throwException $ error "filename field missing"
      filenameValue `shouldEqual` filename

      -- Check reverseLoop
      reverseLoopValue <- case lookup "reverseLoop" jsonObj of
        Just rl -> liftEffect $ readForeignBoolean rl
        Nothing -> liftEffect $ throwException $ error "reverseLoop field missing"
      reverseLoopValue `shouldEqual` reverseLoop

      -- Check artist
      artistValue <- case lookup "artist" jsonObj of
        Just a -> liftEffect $ readForeignString a
        Nothing -> liftEffect $ throwException $ error "artist field missing"
      artistValue `shouldEqual` artist

      -- Check title
      titleValue <- case lookup "title" jsonObj of
        Just t -> liftEffect $ readForeignString t
        Nothing -> liftEffect $ throwException $ error "title field missing"
      titleValue `shouldEqual` title

      -- Check subtitles array
      subtitlesArray <- case lookup "subtitles" jsonObj of
        Just st -> liftEffect $ readForeignArray st
        Nothing -> liftEffect $ throwException $ error "subtitles field missing"
      (length subtitlesArray) `shouldEqual` 1

      -- Check first subtitle
      subtitleJson <- case index subtitlesArray 0 of
        Just s -> pure s
        Nothing -> liftEffect $ throwException $ error "subtitle missing in array"
      let subtitleObj = Foreign.unsafeFromForeign subtitleJson :: Object Foreign

      -- Check subtitle value
      subtitleValue <- case lookup "value" subtitleObj of
        Just v -> liftEffect $ readForeignString v
        Nothing -> liftEffect $ throwException $ error "value field missing in subtitle"
      subtitleValue `shouldEqual` "Test subtitle"

      -- Check subtitle font
      subtitleFont <- case lookup "font" subtitleObj of
        Just f -> liftEffect $ readForeignString f
        Nothing -> liftEffect $ throwException $ error "font field missing in subtitle"
      subtitleFont `shouldEqual` "Impact"

      -- Check subtitle color
      subtitleColor <- case lookup "color" subtitleObj of
        Just c -> liftEffect $ readForeignString c
        Nothing -> liftEffect $ throwException $ error "color field missing in subtitle"
      subtitleColor `shouldEqual` "#ffffff"

      -- Check subtitle position
      subtitlePosition <- case lookup "screenPosition" subtitleObj of
        Just p -> liftEffect $ readForeignString p
        Nothing -> liftEffect $ throwException $ error "screenPosition field missing in subtitle"
      subtitlePosition `shouldEqual` "Top"

      -- Check subtitle size
      subtitleSize <- case lookup "size" subtitleObj of
        Just s -> liftEffect $ readForeignInt s
        Nothing -> liftEffect $ throwException $ error "size field missing in subtitle"
      subtitleSize `shouldEqual` 24

      pure unit
