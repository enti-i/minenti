# Prebuilt Artifacts

This directory is reserved for locally built binaries that you want to package
after compiling Minenti. Because the repository is distributed as source, the
Git configuration ignores the actual executables—only documentation lives
here.

Suggested workflow:

1. Build the dedicated server (`luantiserver`) using the instructions in the
   top-level README or `doc/compiling/linux.md`.
2. Copy the resulting binary into `dist/linux-headless/` (create a new
   subdirectory if you are targeting another platform).
3. Share the folder contents outside of Git, e.g., via an archive upload or
   file hosting service.

Remember to rebuild whenever your environment or dependencies change, since no
precompiled artifacts are tracked with the source code.
