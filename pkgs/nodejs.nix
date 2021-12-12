{ lib }:
let
  urls = {
    aarch64-darwin = https://nodejs.org/dist/v16.13.1/node-v16.13.1-darwin-arm64.tar.gz;
    x86_64-darwin = https://nodejs.org/dist/v16.13.1/node-v16.13.1-darwin-x86.tar.gz;
  };
  src = builtins.fetchTarball urls."${builtins.currentSystem}";

in
src
