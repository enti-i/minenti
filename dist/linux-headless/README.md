# GNU/Linux Headless Server Package Stub

Place your locally compiled `luantiserver` binary in this folder to keep a
portable copy of the dedicated server alongside configuration files.

## How to Populate

1. Build Minenti with `cmake --build build -j$(nproc)` (or equivalent).
2. Copy `build/bin/luantiserver` here and make it executable (`chmod +x`).
3. (Optional) Add helper scripts or configs that you want to bundle with the
   binary.

## Usage

Once populated, you can launch the server with:

```bash
./dist/linux-headless/luantiserver --config minetest.conf.example
```

The `dist/` tree is ignored by Git except for documentation, so remember to
distribute any binaries through an external channel instead of committing them.
