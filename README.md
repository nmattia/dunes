`.envrc`:

```bash
set -euo pipefail

export DUNES_EXTRA_PACKAGES="foo=bar.nix,baz=quux.nix"

res=$(nix-build --no-link \
  -E '(import (builtins.fetchTarball https://github.com/nmattia/dunes/tarball/main))' \
  -A load
)
. "$res"
```


`dunes.toml`:

```bash
packages = [ "nodejs" ]
home = ".home"

[env]
FOO="bar"
```


Recommandation: install a working C toolchain through x code
