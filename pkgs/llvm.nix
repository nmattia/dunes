{ lib }:
let
  src = builtins.fetchTarball https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang+llvm-13.0.0-x86_64-apple-darwin.tar.xz;
in
  lib.runCommand "llvm" {} ''
  export PATH=/usr/sbin:/usr/bin:/bin

  mkdir -p $out
  cd $out
  ln -s ${src}/bin ./bin
  ''
