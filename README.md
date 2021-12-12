

`.envrc`:

``` bash
res=$(nix-build --no-link ./default.nix -A load)
watch_file ./default.nix
. "$res"
```
