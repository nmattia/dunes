{ dunesToml ? "${builtins.getEnv "PWD"}/dunes.toml" }:
let
  lib = import ./lib.nix;

  split = b: str: builtins.filter (e: builtins.typeOf e != "list") (builtins.split b str);

  allPackages =
    let
      extraPackagesPairs = (builtins.filter (e: e != "") (split "[,]" (builtins.getEnv "DUNES_EXTRA_PACKAGES")));
      splitPair = str:
        let pairRaw = split "[=]" str;
        in
        if builtins.length pairRaw == 2
        then
          { name = builtins.elemAt pairRaw 0; value = import (builtins.elemAt pairRaw 1) { inherit lib; }; }
        else
          throw "Format: <name>=<file.nix>, got ${str}";
      extraPackages =
        builtins.listToAttrs (builtins.map splitPair extraPackagesPairs);
    in
    extraPackages //
    {
      nodejs = import ./pkgs/nodejs.nix { inherit lib; };
      cmake = import ./pkgs/cmake.nix { inherit lib; };
      openssl = import ./pkgs/openssl.nix { inherit lib; };
      cargo = import ./pkgs/cargo.nix { inherit lib; };
      llvm = import ./pkgs/llvm.nix { inherit lib; };
    };

  dunes = builtins.fromTOML (builtins.readFile dunesToml);

  # list of packages that must have a 'bin' dir and executables inside
  pkgs =
    let
      filterAttrs = attrNames:
        assert (builtins.all (e: builtins.typeOf e == "string") attrNames);
        let
          attrNamesAttrs = builtins.listToAttrs (map (e: { name = e; value = null; }) attrNames);
        in
        builtins.intersectAttrs attrNamesAttrs;
      packagesList = dunes.packages;
    in
    [
      dunes-run
      dunes-print-sandbox-profile
    ] ++ builtins.attrValues (filterAttrs packagesList allPackages);

  freePackages = [ dunes-free ];

  sandboxedPackages = pkgs;

  # Run a non-dunes package (like ls) in the dunes sandboxed environment
  dunes-run = lib.runCommand "dunes-run" { }
    ''
      export PATH=/usr/sbin:/usr/bin:/bin
      mkdir -p $out/bin
      cat > $out/bin/dunes-run <<EOF
      "\$@"
      EOF

      chmod +x $out/bin/dunes-run
    '';

  # Run a sandboxed dune package without sandboxing
  dunes-free = lib.runCommand "dunes-free" { }
    ''
      export PATH=/usr/sbin:/usr/bin:/bin
      mkdir -p $out/bin
      cat > $out/bin/dunes-free <<EOF
        PATH=${wrapPackages { packages = sandboxedPackages; name = "jailbroken"; sandboxed = false; }}/bin:$PATH "\$@"
      EOF

      chmod +x $out/bin/dunes-free
    '';

  profile_sb = builtins.toFile "profile.sb" (import ./profile.sb.nix);

  dunes-print-sandbox-profile = lib.runCommand "dunes-show-profile" { } ''
    export PATH=/usr/sbin:/usr/bin:/bin
    mkdir -p $out/bin
    cat > $out/bin/dunes-show-profile <<EOF
      cat ${profile_sb}
    EOF
    chmod +x $out/bin/dunes-show-profile
  '';

  # wrap packages into a single "package" (i.e. single bin)
  wrapPackages =
    {
      # list of packages that must include a "bin/" directory
      packages
    , name
    , sandboxed
    }:

    lib.runCommand "dune-${name}-packages" { inherit packages; } ''
      export PATH=/usr/bin:/bin

      mkdir -p $out/bin

      for package in $packages; do

        echo looking for executables in "$package"

        shopt -s nullglob

        for exe in "$package"/bin/*; do
          exe=$(basename "$exe")
          echo found exe "$exe"

          cat > $out/bin/$exe <<EOF
            #!/usr/bin/env bash
            set -euo pipefail
            export HOME=${builtins.getEnv "PWD" + "/" + dunes.home }
            ${if sandboxed then
            ''
            # we need to re-export the path, otherwise $exe will pick up other
            # wrapped executables, trying to execute a nested sandbox.
            PATH=${builtins.concatStringsSep ":" (builtins.map (e: "${e}/bin") packages)}:$PATH \
              /usr/bin/sandbox-exec -f ${profile_sb}  $package/bin/$exe "\$@"
            '' else ''
            $package/bin/$exe "\$@"
            ''
          }
      EOF
          chmod +x "$out/bin/$exe"

          echo written "$out/bin/$exe"
        done
      done
    '';

  load = lib.runCommand "dunes-load" { } ''
    export PATH=/usr/bin:/bin

    cat > $out <<EOF
    # First export all the environment variables
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (k: v: "export ${k}='${v}'") (dunes.env or {})))}
    # Then create the PATH
    export PATH=${wrapPackages { packages = sandboxedPackages; name = "sandboxed"; sandboxed = true; }}/bin:${wrapPackages { packages = freePackages; name = "free"; sandboxed = false; }}/bin:\$PATH
    EOF
  '';

in
{ inherit load; }
