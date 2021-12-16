{ lib }:
let
  urls = {
    aarch64-darwin = https://nodejs.org/dist/v16.13.1/node-v16.13.1-darwin-arm64.tar.gz;
    x86_64-darwin = https://nodejs.org/dist/v16.13.1/node-v16.13.1-darwin-x64.tar.gz;
  };
  src = builtins.fetchTarball { url = urls."${builtins.currentSystem}"; name = "nodejs"; };

in
src
