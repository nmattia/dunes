with
{ home = builtins.getEnv "HOME";
  root = builtins.getEnv "PWD";
};
''
  (version 1)
  (allow default)
  (allow network*)
  (deny file* (subpath "${home}"))
  (allow file-read-metadata (subpath "${home}"))
  (allow file* (subpath "${root}"))
  (deny file* (subpath "/Applications"))
  (deny file* (subpath "${home}/Applications"))
  (allow file* (subpath "${home}/Library/Caches/node-gyp"))
''
