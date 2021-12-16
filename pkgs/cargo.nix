{ lib }:

let

  rust-toolchain-src = builtins.fetchurl https://static.rust-lang.org/dist/rust-1.54.0-x86_64-apple-darwin.pkg;

  # found in https://static.rust-lang.org/dist/channel-rust-stable.toml through
  # https://github.com/rust-lang/cargo/issues/9733
  rust-std-wasm32 = builtins.fetchTarball https://static.rust-lang.org/dist/2021-07-29/rust-std-1.54.0-wasm32-unknown-unknown.tar.gz;


in

  lib.runCommand "rust" {} ''
    export PATH=/usr/sbin:/usr/bin:/bin

    pkgutil --expand ${rust-toolchain-src} $out
    cp -r $out/rust-std.pkg/Scripts/rust-std-x86_64-apple-darwin/lib/rustlib/x86_64-apple-darwin/lib $out/rustc.pkg/Scripts/rustc/lib/rustlib/x86_64-apple-darwin/
    cp -r ${rust-std-wasm32}/rust-std-wasm32-unknown-unknown/lib/rustlib/wasm32-unknown-unknown $out/rustc.pkg/Scripts/rustc/lib/rustlib/

    shopt -s nullglob
    mkdir -p $out/bin

    # link all the rust and cargo executables to /bin/<exe>

    for exe in $out/rustc.pkg/Scripts/rustc/bin/*
    do
      ln -s $exe $out/bin/$(basename $exe)
    done

    for exe in $out/cargo.pkg/Scripts/cargo/bin/*
    do
      ln -s $exe $out/bin/$(basename $exe)
    done
  ''
