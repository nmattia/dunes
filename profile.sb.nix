''
  (version 1)
  (allow default)
  (allow network*)
  (deny file* (subpath "/Users/nicolas"))
  (allow file-read-metadata (subpath "/Users/nicolas"))
  ${
    let
      root = builtins.getEnv "COMFY_ROOT";
    in
    if root != ""
    then "(allow file* (subpath \"${root}\"))"
    else ""
  }
  (deny file* (subpath "/Applications"))
  (deny file* (subpath "/Users/nicolas/Applications"))
  (allow file* (subpath "/Users/nicolas/Library/Caches/node-gyp"))
''
