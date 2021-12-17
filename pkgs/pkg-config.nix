{ lib }:
let
  src = builtins.fetchTarball "https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz";

in

  lib.runCommand "pkg-config" {} ''
  export PATH=/usr/sbin:/usr/bin:/bin

  cp -r ${src}/* .
  chmod -R +w .

  ./configure --with-internal-glib --prefix $out

  make
  make install

  ''
