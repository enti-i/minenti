<div align="center">
    <h1>Minenti</h1>
    <p><strong>Creative worlds. Endless possibilities.</strong></p>
    <img src="https://github.com/luanti-org/luanti/workflows/build/badge.svg" alt="Build Status">
    <a href="https://hosted.weblate.org/engage/minetest/?utm_source=widget"><img src="https://hosted.weblate.org/widgets/minetest/-/svg-badge.svg" alt="Translation status"></a>
    <a href="https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html"><img src="https://img.shields.io/badge/license-LGPLv2.1%2B-blue.svg" alt="License"></a>
</div>
<br>

Minenti is a free open-source voxel game engine with easy modding and game creation.
It is compatible with most Minetest content while adding its own curated
experience, enhanced visual identity, and the new `minenti_features` gameplay
module shipping 100 opt-in abilities ranging from traversal boosts to world
scans. Whether you want to host a server, build games, or experiment with the
engine, this repository contains everything you need.

Copyright (C) 2010-2025 Perttu Ahola <celeron55@gmail.com>
and contributors (see source file comments and the version control log)

Table of Contents
------------------

1. [Project Overview](#project-overview)
2. [Further Documentation](#further-documentation)
3. [Default Controls](#default-controls)
4. [Paths](#paths)
5. [Configuration File](#configuration-file)
6. [Command-line Options](#command-line-options)
7. [Compiling](#compiling)
8. [Docker](#docker)
9. [Version Scheme](#version-scheme)


Project Overview
----------------
- **Engine & game platform**: Create your own worlds, extend the engine through
  Lua mods, and host multiplayer experiences.
- **Included content**: Ships with the `minenti_features` demo mod that
  registers 100 player abilities you can enable via chat commands or reference
  when building your own creations.
- **Modding-first workflow**: Lua API compatibility makes it easy to reuse
  Minetest community mods while layering new mechanics.
- **Cross-platform**: Supports Linux, Windows, macOS, Android, and more through
  the Irrlicht-based rendering stack.

If you are looking for a curated gameplay showcase, load the
`minenti_features` mod in your world and try `/minenti_features help` once in
game to browse the available abilities.


Further documentation
----------------------
- Website: https://www.luanti.org/
- Minenti Documentation: https://docs.luanti.org/
- Forum: https://forum.luanti.org/
- GitHub: https://github.com/luanti-org/luanti/
- [Developer documentation](doc/developing/)
- [doc/](doc/) directory of source distribution

Default controls
----------------
All controls are re-bindable using settings.
Some can be changed in the key config dialog in the settings tab.

| Button                        | Action                                                         |
|-------------------------------|----------------------------------------------------------------|
| Move mouse                    | Look around                                                    |
| W, A, S, D                    | Move                                                           |
| Space                         | Jump/move up                                                   |
| Shift                         | Sneak/move down                                                |
| Q                             | Drop itemstack                                                 |
| Shift + Q                     | Drop single item                                               |
| Left mouse button             | Dig/punch/use                                                  |
| Right mouse button            | Place/use                                                      |
| Shift + right mouse button    | Build (without using)                                          |
| I                             | Inventory menu                                                 |
| Mouse wheel                   | Select item                                                    |
| 0-9                           | Select item                                                    |
| Z                             | Zoom (needs zoom privilege)                                    |
| T                             | Chat                                                           |
| /                             | Command                                                        |
| Esc                           | Pause menu/abort/exit (pauses only singleplayer game)          |
| Shift + Esc                   | Exit directly to main menu from anywhere, bypassing pause menu |
| +                             | Increase view range                                            |
| -                             | Decrease view range                                            |
| K                             | Enable/disable fly mode (needs fly privilege)                  |
| J                             | Enable/disable fast mode (needs fast privilege)                |
| H                             | Enable/disable noclip mode (needs noclip privilege)            |
| E                             | Aux1 (Move fast in fast mode. Games may add special features)  |
| C                             | Cycle through camera modes                                     |
| V                             | Cycle through minimap modes                                    |
| Shift + V                     | Change minimap orientation                                     |
| F1                            | Hide/show HUD                                                  |
| F2                            | Hide/show chat                                                 |
| F3                            | Disable/enable fog                                             |
| F4                            | Disable/enable camera update (Mapblocks are not updated anymore when disabled, disabled in release builds)  |
| F5                            | Cycle through debug information screens                        |
| F6                            | Cycle through profiler info screens                            |
| F10                           | Show/hide console                                              |
| F12                           | Take screenshot                                                |

Paths
-----
Locations:

* `bin`   - Compiled binaries
* `dist`  - Placeholder for locally packaged executables you build yourself (binaries are ignored in source control)
* `share` - Distributed read-only data
* `user`  - User-created modifiable data

Where each location is on each platform:

* Windows .zip / RUN_IN_PLACE source:
    * `bin`   = `bin`
    * `share` = `.`
    * `user`  = `.`
* Windows installed:
    * `bin`   = `C:\Program Files\Minenti\bin (Depends on the install location)`
    * `share` = `C:\Program Files\Minenti (Depends on the install location)`
    * `user`  = `%APPDATA%\Minenti` or `%MINENTI_USER_PATH%`
* Linux installed:
    * `bin`   = `/usr/bin`
    * `share` = `/usr/share/minenti`
    * `user`  = `~/.minenti` or `$MINENTI_USER_PATH`
* macOS:
    * `bin`   = `Contents/MacOS`
    * `share` = `Contents/Resources`
    * `user`  = `Contents/User` or `~/Library/Application Support/Minenti` or `$MINENTI_USER_PATH`

Worlds can be found as separate folders in: `user/worlds/`

Configuration file
------------------
- Default location:
    `user/minenti.conf`
- This file is created by closing Minenti for the first time.
- A specific file can be specified on the command line:
    `--config <path-to-file>`
- A run-in-place build will look for the configuration file in
    `location_of_exe/../minenti.conf` and also `location_of_exe/../../minenti.conf`

Command-line options
--------------------
- Use `--help`

Compiling
---------

The project uses CMake and supports building as a run-in-place binary or an
installed system package. The following instructions cover the most common
platforms. Refer to the linked documentation for deeper customization or
troubleshooting tips.

### GNU/Linux

1. Install the required build tools and dependencies (example for Debian/Ubuntu):
   ```bash
   sudo apt update
   sudo apt install build-essential cmake libirrlicht-dev libbz2-dev \
       libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev \
       libogg-dev libvorbis-dev libopenal-dev libcurl4-openssl-dev
   ```
2. Configure the project in a new build directory:
   ```bash
   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
   ```
3. Compile and install/run:
   ```bash
   cmake --build build -j$(nproc)
   # optional install
   sudo cmake --install build
   # run without installing (run-in-place)
   ./build/bin/minenti
   ```

After compiling once, you can copy the resulting `bin/luantiserver` into
`dist/linux-headless/` for convenience. The tree under `dist/` is intentionally
empty in Git so contributors avoid checking in large binaries. See
`dist/README.md` for packaging tips.

### Windows (MSVC)

1. Install the latest [Visual Studio](https://visualstudio.microsoft.com/) with
   the "Desktop development with C++" workload.
2. Install [vcpkg](https://github.com/microsoft/vcpkg) (already bundled in this
   repository via `vcpkg.json`).
3. Generate the Visual Studio solution using CMake (from a "Developer Command
   Prompt for VS"):
   ```cmd
   cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -G "Visual Studio 17 2022"
   ```
4. Open `build/Minenti.sln` in Visual Studio and build the `minenti` target, or
   compile via CLI:
   ```cmd
   cmake --build build --config RelWithDebInfo
   ```
5. Launch `build/bin/RelWithDebInfo/minenti.exe` (run-in-place) or install with
   `cmake --install build --config RelWithDebInfo`.

### macOS

1. Install the Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```
2. Install dependencies via [Homebrew](https://brew.sh/):
   ```bash
   brew install cmake freetype gettext jpeg libogg libpng libvorbis openal-soft
   ```
3. Configure and build:
   ```bash
   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
   cmake --build build -j$(sysctl -n hw.ncpu)
   ```
4. Run from `build/bin/minenti` or install with `cmake --install build`.

For additional options (Android builds, cross-compilation, packaging, etc.),
consult:

- [Compiling - common information](doc/compiling/README.md)
- [Compiling on GNU/Linux](doc/compiling/linux.md)
- [Compiling on Windows](doc/compiling/windows.md)
- [Compiling on MacOS](doc/compiling/macos.md)

Docker
------

- [Developing minetestserver with Docker](doc/developing/docker.md)
- [Running a server with Docker](doc/docker_server.md)

Version scheme
--------------
We use `major.minor.patch` since 5.0.0-dev. Prior to that we used `0.major.minor`.

- Major is incremented when the release contains breaking changes, all other
numbers are set to 0.
- Minor is incremented when the release contains new non-breaking features,
patch is set to 0.
- Patch is incremented when the release only contains bugfixes and very
minor/trivial features considered necessary.

Since 5.0.0-dev and 0.4.17-dev, the dev notation refers to the next release,
i.e.: 5.0.0-dev is the development version leading to 5.0.0.
Prior to that we used `previous_version-dev`.
