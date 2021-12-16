

`.envrc`:

``` bash
export DUNES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DUNES_PACKAGES="nodejs,cmake"
export DUNES_EXTRA_PACKAGES="foo=bar.nix,baz=quux.nix"

res=$(nix-build --no-link ./default.nix -A load)
watch_file ./default.nix
. "$res"
```
