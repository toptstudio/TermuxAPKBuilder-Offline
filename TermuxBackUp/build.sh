```bash
#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Keep these files in the same folder as this script:
#   - build.sh
#   - android.jar
#   - r8.jar
#   - your keystore file
#
# Edit the keystore filename below to match your file name exactly.
ANDROID_JAR="$PROJECT_DIR/android.jar"
R8_JAR="$PROJECT_DIR/r8.jar"
SIGN_KEYSTORE_NAME="your-keystore-name.keystore"
SIGN_KEYSTORE="$PROJECT_DIR/$SIGN_KEYSTORE_NAME"

RES_DIR="$PROJECT_DIR/res"
MANIFEST="$PROJECT_DIR/AndroidManifest.xml"
SRC_DIR="$PROJECT_DIR/src"
GEN_DIR="$PROJECT_DIR/gen"
OBJ_DIR="$PROJECT_DIR/obj"
BIN_DIR="$PROJECT_DIR/bin"

echo "== APK Builder Offline =="

if [ ! -f "$ANDROID_JAR" ]; then
    echo "❌ android.jar not found in: $PROJECT_DIR"
    exit 1
fi

if [ ! -f "$R8_JAR" ]; then
    echo "❌ r8.jar not found in: $PROJECT_DIR"
    exit 1
fi

echo "✅ Required core jars found"

rm -rf "$GEN_DIR" "$OBJ_DIR" "$BIN_DIR"
mkdir -p "$GEN_DIR" "$OBJ_DIR" "$BIN_DIR"

echo "📦 Compiling resources..."
aapt2 compile -o "$GEN_DIR/compiled.zip" --dir "$RES_DIR"
aapt2 link -I "$ANDROID_JAR" --manifest "$MANIFEST" --java "$GEN_DIR" \
    -o "$BIN_DIR/resources.apk" "$GEN_DIR/compiled.zip"

OLD_R=$(find "$SRC_DIR" -name "R.java" 2>/dev/null | head -n 1 || true)
if [ -n "${OLD_R:-}" ]; then
    rm -f "$OLD_R"
fi

echo "☕ Compiling Java sources..."
JAVA_SOURCES=$(find "$SRC_DIR" -name "*.java" 2>/dev/null || true)
GEN_SOURCES=$(find "$GEN_DIR" -name "*.java" 2>/dev/null || true)

if [ -z "$JAVA_SOURCES$GEN_SOURCES" ]; then
    echo "❌ No Java source files found"
    exit 1
fi

javac -d "$OBJ_DIR" \
    -classpath "$ANDROID_JAR" \
    -source 1.8 -target 1.8 -Xlint:-options \
    $JAVA_SOURCES \
    $GEN_SOURCES

echo "🧩 Dexing with R8..."
DEX_DIR="$GEN_DIR/dex"
mkdir -p "$DEX_DIR"

java -Xmx1024m -cp "$R8_JAR" com.android.tools.r8.D8 \
    --lib "$ANDROID_JAR" \
    --min-api 21 \
    --classpath "$ANDROID_JAR" \
    --output "$DEX_DIR" \
    $(find "$OBJ_DIR" -name "*.class" 2>/dev/null || true)

echo "📦 Packaging APK..."
cp "$BIN_DIR/resources.apk" "$BIN_DIR/app-unsigned.apk"

if compgen -G "$DEX_DIR/*.dex" > /dev/null; then
    for f in "$DEX_DIR"/*.dex; do
        zip -q "$BIN_DIR/app-unsigned.apk" "$(basename "$f")" -j "$f"
    done
else
    echo "❌ No .dex files were generated"
    exit 1
fi

echo "🔑 Signing APK..."
if [ ! -f "$SIGN_KEYSTORE" ]; then
    echo "❌ Keystore not found: $SIGN_KEYSTORE"
    echo "✅ Put your keystore file in the same folder as build.sh and set SIGN_KEYSTORE_NAME correctly."
    exit 1
fi

apksigner sign \
    --ks "$SIGN_KEYSTORE" \
    --ks-type PKCS12 \
    --ks-pass pass:android \
    --key-pass pass:android \
    --ks-key-alias android \
    --out "$BIN_DIR/app-debug.apk" \
    "$BIN_DIR/app-unsigned.apk"

TARGET="/sdcard"
if [ ! -d "$TARGET" ] || [ ! -w "$TARGET" ]; then
    TARGET="/storage/emulated/0"
fi

if [ -d "$TARGET" ] && [ -w "$TARGET" ]; then
    cp "$BIN_DIR/app-debug.apk" "$TARGET/app-debug.apk"
    echo "✅ APK copied to $TARGET/app-debug.apk"
else
    echo "❌ Cannot write to internal storage"
    exit 1
fi
```
