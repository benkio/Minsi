{ name = "my-project"
, dependencies =
  [ "console"
  , "effect"
  , "express"
  , "foldable-traversable"
  , "node-child-process"
  , "node-path"
  , "prelude"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
