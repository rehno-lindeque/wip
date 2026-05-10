{sidecar}:

sidecar.overrideAttrs (old: {
  patches = (old.patches or []) ++ [./gitstatus-folder-truncation.patch];
})
