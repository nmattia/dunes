{ lib }:
let
  src = builtins.fetchTarball { url = https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-macos-universal.tar.gz; name = "cmake-src"; };
in
lib.runCommand "cmake" { } ''
  export PATH=/usr/sbin:/usr/bin:/bin

  mkdir -p $out
  cd $out
  ln -s ${src}/CMake.app/Contents/bin ./bin
''
