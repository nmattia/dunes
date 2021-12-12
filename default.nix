let
  runCommand = name: env: cmd: builtins.derivation
    (
      rec {
        inherit name;
        builder = /bin/bash;
        args = [ "-euo" "pipefail" "-c" input ];
        system = builtins.currentSystem;
        input = cmd;
      } // env
    );

  lib = { inherit runCommand; };

  nodejs = import ./pkgs/nodejs.nix { inherit lib; };
  cmake = import ./pkgs/cmake.nix { inherit lib; };

  vanillaPathBits = [
    inenv
    nodejs
    cmake
  ];

  inenv = runCommand "inenv" { }
    ''
      export PATH=/usr/sbin:/usr/bin:/bin
      mkdir -p $out/bin
      cat > $out/bin/inenv <<EOF
      "\$@"
      EOF

      chmod +x $out/bin/inenv
    '';

  profile_sb = import ./profile.sb.nix;

  vanillaPath = builtins.concatStringsSep ":" vanillaPathBits;

  final = runCommand "final" { inherit vanillaPathBits; } ''
    export PATH=/usr/bin:/bin

    mkdir -p $out/bin

    for bit in $vanillaPathBits; do
      echo looking for executables in "$bit"

      shopt -s nullglob

      for exe in "$bit"/bin/*; do
        exe=$(basename "$exe")
        echo found exe "$exe"


        cat > $out/bin/$exe <<EOF
          #!/usr/bin/env bash
          set -euo pipefail
          export HOME=/nowhere

          if [ "\''${SHELL_NO_SANDBOX:-}" == "1" ]
          then
            $bit/bin/$exe "\$@"
          else
            /usr/bin/sandbox-exec -f ${builtins.toFile "profile.sb" profile_sb} $bit/bin/$exe "\$@"
          fi
    EOF
        chmod +x "$out/bin/$exe"

        echo written "$out/bin/$exe"
      done
    done
  '';

  load = runCommand "load" { } ''
    export PATH=/usr/bin:/bin

    cat > $out <<EOF
    export PATH=${final}/bin:\$PATH
    EOF
  '';

in
{ inherit final load; }
