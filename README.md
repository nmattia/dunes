`.envrc`:

``` bash
set -euo pipefail

export DUNES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DUNES_PACKAGES="nodejs,cmake"
export DUNES_EXTRA_PACKAGES="foo=bar.nix,baz=quux.nix"

res=$(nix-build --no-link \
  -E '(import (builtins.fetchTarball https://github.com/nmattia/dunes/tarball/main))' \
  -A load
)
. "$res"
```
