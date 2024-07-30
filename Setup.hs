import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Setup
import Distribution.Simple.BuildPaths ( exeExtension )
import Distribution.PackageDescription
import Distribution.System ( buildPlatform )

import System.FilePath
import System.Process ( callCommand )
import System.IO

main :: IO ()
main = defaultMainWithHooks userhooks

userhooks :: UserHooks
userhooks = simpleUserHooks
  { copyHook  = copyHook'
  , instHook  = instHook'
  }

instHook' :: PackageDescription -> LocalBuildInfo -> UserHooks -> InstallFlags -> IO ()
instHook' pd lbi hooks flags = instHook simpleUserHooks pd lbi hooks flags

copyHook' :: PackageDescription -> LocalBuildInfo -> UserHooks -> CopyFlags -> IO ()
copyHook' pd lbi hooks flags = do
  -- Copy library and executable etc.
  copyHook simpleUserHooks pd lbi hooks flags
  -- Run me
  runMe pd lbi
  -- Copy again.
  copyHook simpleUserHooks pd lbi hooks flags

self :: String
self = "issue10235"

runMe :: PackageDescription -> LocalBuildInfo -> IO ()
runMe pd lbi = do

  -- for debugging, these are examples how you can inspect the flags...
  -- print $ flagAssignment lbi
  -- print $ fromPathTemplate $ progSuffix lbi

  let bdir = buildDir lbi
      me   = bdir </> self </> self <.> exeExtension buildPlatform

  _ <- callCommand me
  return ()
