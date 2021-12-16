with
{ user = builtins.getEnv "USER";
  root = builtins.getEnv "DUNES_ROOT";
};
assert user != "";
''
  (version 1)
  (allow default)
  (allow network*)
  (deny file* (subpath "/Users/nicolas"))
  (allow file-read-metadata (subpath "/Users/nicolas"))
  (allow file* (subpath "${root}"))
  (deny file* (subpath "/Applications"))
  (deny file* (subpath "/Users/nicolas/Applications"))
  (allow file* (subpath "/Users/nicolas/Library/Caches/node-gyp"))
''
