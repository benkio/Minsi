{ name = "my-project"
, dependencies = 
  [ "console"
  , "effect"
  , "express"
  , "node-path"
  , "prelude"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
