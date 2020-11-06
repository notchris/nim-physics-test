# Package

version = "0.0.0"
author = "Chris McGrane"
description = "a game test"
license = "?"

# Deps
requires "nim >= 1.4.0"
requires "nico >= 0.3.2"

task runr, "Runs game for current platform":
 exec("echo 'GAME PHYSICS PLAYGROUND'")
 exec "nim c -r --multimethods:on -d:release -o:boot boot.nim"