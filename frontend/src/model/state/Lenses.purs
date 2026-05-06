module Model.State.Lenses
  ( _filename
  , _source
  , _subtitles
  ) where

import Prelude

import Data.Lens (Lens')
import Data.Lens.Iso.Newtype (unto)
import Data.Lens.Record (prop)
import Model.State.State (State(..), Source, Subtitle)
import Node.Path (FilePath)
import Type.Proxy (Proxy(..))

_filename :: Lens' State FilePath
_filename = unto State <<< prop (Proxy :: Proxy "filename")

_source :: Lens' State Source
_source = unto State <<< prop (Proxy :: Proxy "source")

_subtitles :: Lens' State (Array Subtitle)
_subtitles = unto State <<< prop (Proxy :: Proxy "subtitles")
