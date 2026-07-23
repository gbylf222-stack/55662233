#!/bin/bash
set -e

if [ -z "$ANDROID_HOME" ]; then
  echo "请先设置 ANDROID_HOME 环境变量指向你的 Android SDK 目录"
  exit 1
fi

BUILD_TOOLS=$(ls -d "$ANDROID_HOME"/build-tools/*/ | sort -V | tail -1)
PLATFORM=$(ls -d "$ANDROID_HOME"/platforms/*/ | sort -V | tail -1)
AAPT2="${BUILD_TOOLS}aapt2"
ZIPALIGN="${BUILD_TOOLS}zipalign"
APKSIGNER="${BUILD_TOOLS}apksigner"
ANDROID_JAR="${PLATFORM}android.jar"

echo "使用 build-tools: $BUILD_TOOLS"
echo "使用 platform:    $PLATFORM"

rm -rf build
mkdir -p build

echo "== 1. 编译资源 =="
"$AAPT2" compile --dir res -o build/compiled.zip

echo "== 2. 链接生成未签名apk =="
"$AAPT2" link -o build/unsigned.apk \
  --manifest AndroidManifest.xml \
  -I "$ANDROID_JAR" \
  build/compiled.zip

echo "== 3. 对齐 =="
"$ZIPALIGN" -f 4 build/unsigned.apk build/aligned.apk

echo "== 4. 生成签名密钥（如果还没有）=="
if [ ! -f overlay.jks ]; then
  keytool -genkeypair -v \
    -keystore overlay.jks \
    -alias overlay \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass overlay123 -keypass overlay123 \
    -dname "CN=brightness-floor-overlay, OU=local, O=local, L=local, S=local, C=CN"
fi

echo "== 5. 签名 =="
"$APKSIGNER" sign \
  --ks overlay.jks --ks-pass pass:overlay123 --key-pass pass:overlay123 \
  --out BrightnessFloorOverlay.apk \
  build/aligned.apk

echo
echo "完成: $(pwd)/BrightnessFloorOverlay.apk"
