# TermuxAPKBuilder-Offline

> **Restore your Termux Android APK build environment fully offline.**

**TermuxAPKBuilder-Offline** is an offline recovery toolkit for restoring a working Android APK build environment inside Termux without re-downloading packages from the internet.

It is designed for users who want a reliable local restore path for Java, Android build tools, and the supporting libraries needed for APK building. The project also includes a lightweight `build.sh` helper for local APK packaging when the required files are placed in the same folder.

**APK version:** `0.119.0-beta.3`

---

## Features

* Fully offline restore workflow
* Architecture-specific backup archives
* Menu-based restore script
* Android APK build tool support
* Java toolchain support
* Supporting libraries included with the backup
* Build script support for local APK packaging
* Works without internet after the archive is prepared

---

## What this project gives you

This repository provides offline backup archives and a restore menu that help you recover a working Termux build environment from local storage.

It includes:

* Android packaging tools such as `aapt2` and `aapt`
* APK signing support through `apksigner`
* Java tooling through `openjdk-21`
* Supporting libraries required by the toolchain
* A menu-based restore script for local recovery
* Build workflow support through `build.sh`

---

## Why use it

This project is useful when:

* Termux was reinstalled or reset
* your previous build environment was lost
* you need to rebuild APK tools while offline
* your connection is slow, limited, or unavailable
* you want a reusable local restore bundle for multiple devices

---

## Included tools

| Tool         | Purpose                         |
| ------------ | ------------------------------- |
| `aapt2`      | Android resource packaging tool |
| `aapt`       | Android asset packaging tool    |
| `apksigner`  | APK signing utility             |
| `openjdk-21` | Java runtime and compiler       |
| `zip`        | Archive handling utilities      |

The backup also includes supporting shared libraries needed by the packaged tools.

---

## Supported architectures

| Architecture | Archive                   | Status                                                                                                        |
| ------------ | ------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `arm64`      | `TermuxBackUp_arm64.zip`  | Complete                                                                                                      |
| `arm32`      | `TermuxBackUp_arm32.zip`  | Complete                                                                                                      |
| `i686`       | `TermuxBackUp_i686.zip`   | Complete                                                                                                      |
| `x86_64`     | `TermuxBackUp_x86_64.zip` | Mostly complete; a couple of audio-related libraries are omitted because they are not needed for APK building |

---

## Repository layout

```text
TermuxAPKBuilder-Offline/
├── TermuxBackUp_arm64.zip
├── TermuxBackUp_arm32.zip
├── TermuxBackUp_i686.zip
├── TermuxBackUp_x86_64.zip
├── TermuxBackUp/
│   ├── install.txt
│   ├── menu.sh
│   ├── build.sh
│   ├── android.jar
│   ├── r8.jar
│   └── your-keystore-name.keystore
├── LICENSE.md
└── README.md
```

---

## Installation

### 1) Enable shared storage in Termux

Run:

```bash
termux-setup-storage
```

### 2) Extract the backup to Downloads

Unzip the archive directly to:

```text
/sdcard/Download/
```

After extraction, the folder should already exist as:

```text
/sdcard/Download/TermuxBackUp/
```

Do not copy folders manually. The ZIP is already prepared with the correct folder structure.

### 3) Launch the restore menu

Run:

```bash
termux-setup-storage && sleep 4 && bash /sdcard/Download/TermuxBackUp/menu.sh
```

Choose **Restore** from the menu.

The script automatically detects your CPU architecture and installs the matching offline packages.

---

## Verify installation

After restoring, verify the environment:

```bash
uname -m
java -version
javac -version
aapt2 version
apksigner --version
```

If every command returns successfully, the restore completed correctly.

---

## Version information

### Application version

**APK version:** `0.119.0-beta.3`

### Architecture package sets

* backup set `arm64`
* backup set `arm32`
* backup set `i686`
* backup set `x86_64`

### Debian package manifest

Below is the package manifest for the backup set you exported from Termux.

| Package                      | Version      |
| ---------------------------- | ------------ |
| `aapt2`                      | `16.0.0.4-1` |
| `aapt`                       | `16.0.0.4-1` |
| `abseil-cpp`                 | `20260526.0` |
| `alsa-lib`                   | `1.2.16.1`   |
| `alsa-plugins`               | `1.2.12-1`   |
| `apksigner`                  | `37.0.0`     |
| `dbus`                       | `1.16.2-3`   |
| `fmt`                        | `1:11.2.0`   |
| `libandroid-execinfo`        | `0.1-3`      |
| `libandroid-shmem`           | `0.7`        |
| `libandroid-spawn`           | `0.3`        |
| `libandroid-sysv-semaphore`  | `0.1-1`      |
| `libexpat`                   | `2.8.2`      |
| `libflac`                    | `1.5.0-1`    |
| `libjpeg-turbo`              | `3.2.0`      |
| `libltdl`                    | `2.6.2`      |
| `libmp3lame`                 | `3.100-7`    |
| `libogg`                     | `1.3.6-1`    |
| `libopus`                    | `1.6.1`      |
| `libpng`                     | `1.6.58`     |
| `libprotobuf`                | `2:35.1`     |
| `libsndfile`                 | `1.2.2-2`    |
| `libsoxr`                    | `0.1.3-8`    |
| `libvorbis`                  | `1.3.7-4`    |
| `libwebrtc-audio-processing` | `1.3-5`      |
| `libx11`                     | `1.8.13-1`   |
| `libxau`                     | `1.0.12-2`   |
| `libxcb`                     | `1.17.0-1`   |
| `libxdmcp`                   | `1.1.5-2`    |
| `libzopfli`                  | `1.0.3-5`    |
| `littlecms`                  | `2.19.1`     |
| `openjdk-21`                 | `21.0.11`    |
| `pulseaudio`                 | `17.0-1`     |
| `speexdsp`                   | `1.2.1-1`    |
| `xorg-util-macros`           | `1.20.2`     |
| `xorgproto`                  | `2025.1`     |
| `zip`                        | `3.0-7`      |
| `zlib`                       | `1.3.2`      |

---

## Build script note

The repository includes a `build.sh` helper that can be used in the build workflow.

### Required files

Put these files in the **same folder** as `build.sh`:

* `build.sh`
* `android.jar`
* `r8.jar`
* your keystore file

### Keystore setup

The keystore is used for signing the final APK.

In `build.sh`, set this value manually:

```bash
SIGN_KEYSTORE_NAME="your-keystore-name.keystore"
```

Replace `your-keystore-name.keystore` with your real keystore filename.

### Important note

The keystore file must be placed in the same folder as `build.sh`, `android.jar`, and `r8.jar`.

Example:

```text
project-folder/
├── build.sh
├── android.jar
├── r8.jar
└── your-keystore-name.keystore
```

### What the script does

* checks that `android.jar` is present
* checks that `r8.jar` is present
* compiles resources with `aapt2`
* compiles Java sources with `javac`
* converts classes to dex with `R8`
* signs the APK using your keystore
* copies the final APK to internal storage

---

## Troubleshooting

### `aapt2: cannot execute: required file not found`

This usually means one of the following:

* the wrong architecture archive was used
* extraction was incomplete
* a required shared library is missing
* the binary was corrupted during copy or unzip
* the restore folder structure does not match the script’s expectations

Try verifying the architecture first:

```bash
uname -m
```

Then restore the correct archive again.

### Termux cannot access `/sdcard/Download`

Make sure you ran:

```bash
termux-setup-storage
```

Then reopen Termux and try again.

### The script cannot find `menu.sh`

Confirm the file is here:

```text
/sdcard/Download/TermuxBackUp/menu.sh
```

### Java works but APK build tools fail

Check whether the key executables are present:

```bash
which aapt2
which apksigner
which zip
```

---

## Security notes

* This is an unofficial offline restore package.
* The `.deb` packages should be treated as redistributed upstream components.
* Use only the archive that matches your architecture.
* Check files before restoring them on a device you care about.

---

## License

The scripts in this repository are released under the MIT License.

The redistributed `.deb` packages remain under their original upstream open-source licenses.

---

## Credits

* **Termux** — terminal emulator and Linux environment for Android
* **Android Open Source Project** — Android packaging tools
* **OpenJDK** — Java runtime and compiler
* **Upstream Termux package maintainers** — for the packaged dependencies
* **Open-source library authors** — for the supporting components included here

---

## FAQ

### Does this work without internet?

Yes. That is the main purpose of the project.

### Does it require root?

No.

### Can I build APKs after restoring?

Yes. That is the goal of the toolchain.

### Do I need Android Studio?

No. This is a Termux-based offline environment.

### Why are some x86_64 libraries missing?

A couple of audio-related libraries are not included there because they are not needed for APK building.

---

## Final note

This project is meant to help you recover a working APK build environment in Termux quickly, locally, and offline.

**Restore once. Build offline. Keep working.**
