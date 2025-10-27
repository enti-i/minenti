<div align="center">
    <h1>Minenti</h1>
    <p><strong>Kreative Welten. Grenzenlose Möglichkeiten.</strong></p>
    <img src="https://github.com/luanti-org/luanti/workflows/build/badge.svg" alt="Build-Status">
    <a href="https://hosted.weblate.org/engage/minetest/?utm_source=widget"><img src="https://hosted.weblate.org/widgets/minetest/-/svg-badge.svg" alt="Übersetzungsstatus"></a>
    <a href="https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html"><img src="https://img.shields.io/badge/license-LGPLv2.1%2B-blue.svg" alt="Lizenz"></a>
</div>
<br>

Minenti ist eine freie, quelloffene Voxel-Spiel-Engine mit einem starken Fokus auf Modding und der schnellen Erstellung eigener Spiele.

Copyright (C) 2010-2025 Perttu Ahola <celeron55@gmail.com>
und Mitwirkende (siehe Quelltext-Kommentare sowie die Versionskontroll-Historie)

Inhaltsverzeichnis
------------------

1. [Überblick](#überblick)
2. [Weitere Dokumentation](#weitere-dokumentation)
3. [Standardsteuerung](#standardsteuerung)
4. [Pfade](#pfade)
5. [Konfigurationsdatei](#konfigurationsdatei)
6. [Kommandozeilenoptionen](#kommandozeilenoptionen)
7. [Build-Anleitung](#build-anleitung)
    1. [Gemeinsame Voraussetzungen](#gemeinsame-voraussetzungen)
    2. [Linux (Desktop)](#linux-desktop)
    3. [Windows (Visual-Studio-Toolchain)](#windows-visual-studio-toolchain)
    4. [macOS (Homebrew)](#macos-homebrew)
    5. [Android](#android)
8. [Docker](#docker)
9. [Versionsschema](#versionsschema)
10. [Community & Support](#community--support)

Überblick
---------
- Website: https://www.luanti.org/
- Minenti-Dokumentation: https://docs.luanti.org/
- Forum: https://forum.luanti.org/
- GitHub: https://github.com/luanti-org/luanti/
- Entwickler:innen-Dokumentation: [doc/developing/](doc/developing/)

Weitere Dokumentation
----------------------
Alle weiterführenden Informationen, Formatbeschreibungen und Richtlinien finden sich im Verzeichnis [doc/](doc/). Besonders hilfreich sind:

- [doc/world_format.md](doc/world_format.md) für Welt- und Speicherformate
- [doc/lua_api.md](doc/lua_api.md) für die Modding-API
- [doc/settingtypes.txt](builtin/settingtypes.txt) für Konfigurationsoptionen

Standardsteuerung
-----------------
Alle Eingaben lassen sich im Einstellungsmenü anpassen. Wichtige Standard-Tastenbelegungen:

| Taste / Aktion                 | Funktion                                                     |
|--------------------------------|--------------------------------------------------------------|
| Maus bewegen                   | Umschauen                                                    |
| W, A, S, D                     | Bewegung                                                     |
| Leertaste                      | Springen / nach oben fliegen                                 |
| Umschalt                       | Schleichen / nach unten fliegen                              |
| Q                              | Gegenstandsstapel fallen lassen                              |
| Umschalt + Q                   | Einzelnes Item fallen lassen                                 |
| Linke Maustaste                | Graben / schlagen / benutzen                                 |
| Rechte Maustaste               | Platzieren / benutzen                                        |
| I                              | Inventar öffnen                                              |
| Mausrad oder 0-9               | Werkzeug-/Inventar-Slot wählen                               |
| T                              | Chat                                                         |
| /                              | Befehl eingeben                                              |
| ESC                            | Pausemenü / Abbrechen / Verlassen                            |
| Umschalt + ESC                 | Direkt ins Hauptmenü                                         |
| + / -                          | Sichtweite erhöhen / verringern                              |
| K / J / H                      | Flugmodus / Schnellmodus / Noclip (jeweilige Berechtigung)   |
| Z                              | Zoom (erfordert Zoom-Recht)                                  |
| C                              | Kameraperspektive wechseln                                   |
| V / Umschalt + V               | Minimap-Modus / -Ausrichtung                                 |
| F1 – F6                        | HUD, Chat, Nebel, Debug- & Profiler-Anzeigen                 |
| F10 / F12                      | Konsole / Screenshot                                         |

Pfade
-----
Minenti nutzt drei Basisverzeichnisse:

- `bin` – kompilierte Binaries
- `share` – schreibgeschützte Daten (Textures, Spiele, Übersetzungen)
- `user` – vom Benutzer veränderbare Daten (Welten, Mods, Einstellungen)

Plattformabhängige Standardpfade:

- **Windows ZIP-Archiv / Run-in-place**
  - `bin = bin`
  - `share = .`
  - `user = .`
- **Windows Installation**
  - `bin = C:\Program Files\Minenti\bin`
  - `share = C:\Program Files\Minenti`
  - `user = %APPDATA%\Minenti` oder `%MINENTI_USER_PATH%`
- **Linux Installation**
  - `bin = /usr/bin`
  - `share = /usr/share/minenti`
  - `user = ~/.minenti` oder `$MINENTI_USER_PATH`
- **macOS Anwendungspaket**
  - `bin = Contents/MacOS`
  - `share = Contents/Resources`
  - `user = ~/Library/Application Support/Minenti` oder `$MINENTI_USER_PATH`

Welten liegen standardmäßig in `user/worlds/`.

Konfigurationsdatei
------------------
- Standardpfad: `user/minenti.conf`
- Die Datei wird erzeugt, sobald Minenti zum ersten Mal geschlossen wird.
- Alternativer Pfad über Kommandozeile: `--config <pfad>`
- Run-in-place-Builds suchen zusätzlich in `../minenti.conf` und `../../minenti.conf`
- Wichtige Umgebungsvariablen:
  - `MINENTI_USER_PATH` – überschreibt das Benutzerverzeichnis
  - `MINENTI_DATA_PATH` – verweist auf das geteilte Datenverzeichnis

Kommandozeilenoptionen
----------------------
- `minenti --help` listet alle verfügbaren Optionen.
- Häufig genutzt:
  - `--world <pfad>` – öffnet eine bestimmte Welt direkt
  - `--go` – startet ohne Hauptmenü
  - `--server` – startet den dedizierten Server
  - `--config <pfad>` – liest Einstellungen aus einer alternativen Datei

Build-Anleitung
---------------
Die folgenden Abschnitte erläutern den vollständigen Build-Prozess auf allen wichtigen Plattformen. Jede Anleitung führt von der Installation der Abhängigkeiten bis zum Starten des Spiels.

### Gemeinsame Voraussetzungen
- C++17-fähiger Compiler (GCC ≥ 11, Clang ≥ 13, MSVC ≥ 2022)
- CMake ≥ 3.21
- Ninja (empfohlen) oder Make
- Git
- Abhängigkeiten: IrrlichtMt, SQLite3, Zlib, OpenAL, Vorbis, CURL, Gettext, Freetype, JsonCPP, LuaJIT, GMP, LevelDB/Redis optional

### Linux (Desktop)
1. **Pakete installieren (Beispiel Debian/Ubuntu):**
   ```bash
   sudo apt update
   sudo apt install build-essential ninja-build cmake libirrlichtmt-dev \
        libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-openssl-dev \
        libfreetype6-dev libjsoncpp-dev libluajit-5.1-dev libgettextpo-dev \
        libgmp-dev libssl-dev
   ```
2. **Repository klonen:**
   ```bash
   git clone https://github.com/luanti-org/luanti.git minenti
   cd minenti
   ```
3. **Build-Verzeichnis erstellen und konfigurieren:**
   ```bash
   cmake -S . -B build/linux-release -G Ninja \
        -DENABLE_LUAJIT=ON -DENABLE_FREETYPE=ON -DENABLE_GETTEXT=ON \
        -DENABLE_SOUND=ON -DRUN_IN_PLACE=FALSE -DCMAKE_BUILD_TYPE=Release
   ```
4. **Kompilieren und installieren (optional):**
   ```bash
   cmake --build build/linux-release
   sudo cmake --install build/linux-release
   ```
5. **Entwicklungsversion mit Debug-Infos:**
   ```bash
   cmake -S . -B build/linux-debug -G Ninja -DRUN_IN_PLACE=TRUE -DCMAKE_BUILD_TYPE=Debug
   cmake --build build/linux-debug
   ./build/linux-debug/minenti
   ```

### Windows (Visual-Studio-Toolchain)
1. **Werkzeuge installieren:**
   - Visual Studio 2022 mit „Desktop development with C++“
   - CMake und Ninja (werden mit Visual Studio geliefert oder separat installieren)
   - Vcpkg (empfohlen für Abhängigkeiten)
2. **Abhängigkeiten über vcpkg installieren:**
   ```powershell
   git clone https://github.com/microsoft/vcpkg.git
   .\vcpkg\bootstrap-vcpkg.bat
   .\vcpkg\vcpkg install --triplet x64-windows irrlichtmt[opengl] curl freetype \
       libogg libvorbis openal-soft sqlite3 luajit zlib jsoncpp gmp
   ```
3. **Minenti klonen und konfigurieren:**
   ```powershell
   git clone https://github.com/luanti-org/luanti.git minenti
   cd minenti
   cmake -S . -B build\msvc-release -G "Ninja" `
       -DCMAKE_TOOLCHAIN_FILE=..\vcpkg\scripts\buildsystems\vcpkg.cmake `
       -DENABLE_SOUND=ON -DENABLE_GETTEXT=ON -DCMAKE_BUILD_TYPE=Release
   ```
4. **Bauen und starten:**
   ```powershell
   cmake --build build\msvc-release
   .\build\msvc-release\bin\Minenti.exe
   ```
5. **Debugging in Visual Studio:**
   - `cmake -S . -B build\msvc-debug -G "Visual Studio 17 2022" -A x64 ...`
   - Projektmappe öffnen und F5 drücken

### macOS (Homebrew)
1. **Abhängigkeiten installieren:**
   ```bash
   brew install cmake ninja irrlichtmt freetype luajit sqlite3 jsoncpp \
        libogg libvorbis openal-soft gettext curl gmp
   ```
2. **Repository klonen und konfigurieren:**
   ```bash
   git clone https://github.com/luanti-org/luanti.git minenti
   cd minenti
   cmake -S . -B build/macos-release -G Ninja \
        -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
        -DENABLE_SOUND=ON -DENABLE_GETTEXT=ON -DCMAKE_BUILD_TYPE=Release
   ```
3. **Build ausführen und App starten:**
   ```bash
   cmake --build build/macos-release
   open build/macos-release/Minenti.app
   ```

### Android
Die Android-Toolchain befindet sich im Verzeichnis [`android/`](android/). Eine minimale Schnellstart-Anleitung:

```bash
sudo apt install openjdk-17-jdk android-sdk ndk-build
git clone https://github.com/luanti-org/luanti.git minenti
cd minenti/android
./gradlew assembleRelease
```

Die resultierende APK liegt anschließend unter `android/app/build/outputs/apk/`.

Docker
------
- [Entwicklung mit Docker](doc/developing/docker.md)
- [Server mit Docker betreiben](doc/docker_server.md)

Versionsschema
--------------
Minenti verwendet seit Version 5.0.0-dev ein Semver-ähnliches Schema `Hauptversion.Nebenversion.Patch`:

- **Hauptversion**: Breaking Changes, Nebenversion & Patch werden auf 0 gesetzt
- **Nebenversion**: Neue abwärtskompatible Features, Patch wird auf 0 gesetzt
- **Patch**: Fehlerkorrekturen und kleine Verbesserungen

Während der Entwicklung kennzeichnet die Endung `-dev`, dass es sich um den Vorgänger der nächsten stabilen Version handelt (z. B. `5.8.0-dev`).

Community & Support
-------------------
- Übersetzungen: https://hosted.weblate.org/engage/minetest/
- IRC/Matrix: #minenti im Libera.Chat-Netzwerk bzw. Matrix-Space `#minenti:matrix.org`
- Issue-Tracker: https://github.com/luanti-org/luanti/issues
- Sicherheit: security@luanti.org
