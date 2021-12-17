`.envrc`:

```bash
set -euo pipefail

export DUNES_EXTRA_PACKAGES="foo=bar.nix,baz=quux.nix"

res=$(nix-build --no-link \
  -E '(import (builtins.fetchTarball https://github.com/nmattia/dunes/tarball/main))' \
  -A load
)

watch_file dunes.toml
. "$res"
```


`dunes.toml`:

```bash
packages = [ "nodejs" ]
home = ".home"

[env]
FOO="bar"
```


Recommendation: install a working C toolchain through x code

```
extra-sandbox-paths = /usr/lib /usr/sbin /usr/bin /bin /System /Library
```
