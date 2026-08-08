module Response.CheckDependenciesResponse where

import Contracts.Api (CheckDependenciesResponse)

buildResponse :: Array String -> CheckDependenciesResponse
buildResponse missingDependencies =
  { missedDependencies: missingDependencies }
