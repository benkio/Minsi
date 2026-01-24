module Response.CheckDependenciesResponse where

type CheckDependenciesResponse = { missedDependencies :: Array String }

buildResponse :: Array String -> CheckDependenciesResponse
buildResponse missingDependencies =
  { missedDependencies: missingDependencies }
