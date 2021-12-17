{ lib }:

let
  src = builtins.fetchTarball https://www.openssl.org/source/openssl-1.1.1m.tar.gz;
in
  lib.runCommand "openssl" {} ''
  export PATH=/usr/sbin:/usr/bin:/bin

  set -euo pipefail

  mkdir -p $out

  cp -r ${src}/* .
  chmod -R +w .

  ./Configure --prefix=$out/install --openssldir=$out/ssl darwin64-x86_64-cc

  make

  make install

  echo $out


  ''


