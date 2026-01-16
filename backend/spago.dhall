{ name = "my-project"
, dependencies =
  [ "console"
  , "effect"
  , "exceptions"
  , "express"
  , "foldable-traversable"
  , "node-buffer"
  , "node-child-process"
  , "node-path"
  , "prelude"
  , "spec"
  , "spec-discovery"
  , "stringutils"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
