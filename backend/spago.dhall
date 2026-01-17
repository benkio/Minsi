{ name = "my-project"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "express"
  , "foldable-traversable"
  , "lists"
  , "monad-loops"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-path"
  , "prelude"
  , "spec"
  , "spec-discovery"
  , "strings"
  , "stringutils"
  , "transformers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
