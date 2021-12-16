let
  lib = import ./lib.nix;

  allPackages = {
    nodejs = import ./pkgs/nodejs.nix { inherit lib; };
    cmake = import ./pkgs/cmake.nix { inherit lib; };
  };

  # list of packages that must have a 'bin' dir and executables inside
  pkgs =
    let
      filterAttrs = attrNames:
        let
          attrNamesAttrs = builtins.listToAttrs (map (e: { name = e; value = null; }) attrNames);

        in
        builtins.intersectAttrs attrNamesAttrs;
      packagesList = builtins.split "," (builtins.getEnv "DUNES_PACKAGES");
    in
    assert (builtins.trace packagesList) true;
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
            export HOME=/nowhere

            ${if sandboxed then "/usr/bin/sandbox-exec -f ${profile_sb} " else "" } $package/bin/$exe "\$@"
      EOF
          chmod +x "$out/bin/$exe"

          echo written "$out/bin/$exe"
        done
      done
    '';

  load = lib.runCommand "dunes-load" { } ''
    export PATH=/usr/bin:/bin

    cat > $out <<EOF
    export PATH=${wrapPackages { packages = sandboxedPackages; name = "sandboxed"; sandboxed = true; }}/bin:${wrapPackages { packages = freePackages; name = "free"; sandboxed = false; }}/bin:\$PATH
    EOF
  '';

in
{ inherit load; }
