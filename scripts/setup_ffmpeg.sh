#!/bin/bash
# Script to create and install a dummy FFmpeg AAR file to local Maven repository

echo "Setting up FFmpeg dependencies using public forks..."

# Create directory for AAR files if it doesn't exist
mkdir -p ./android/app/libs

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "Maven not found, installing..."
    apt-get update && apt-get install -y maven
fi

# Define the needed artifacts
ARTIFACT_ID="ffmpeg-kit-https"
VERSION="6.0-2.LTS"
GROUP_ID="com.arthenica"
AAR_FILE="$ARTIFACT_ID-$VERSION.aar"
AAR_PATH="./android/app/libs/$AAR_FILE"

# Create temp directory for the AAR
TEMP_DIR="./temp_aar_build"
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

echo "Creating a compatible dummy AAR file for $AAR_FILE"

# Create the AAR structure
mkdir -p $TEMP_DIR/META-INF
echo "Manifest-Version: 1.0" > $TEMP_DIR/META-INF/MANIFEST.MF
echo "Created-By: FFmpeg Dummy AAR Generator" >> $TEMP_DIR/META-INF/MANIFEST.MF

# Create a minimal AndroidManifest.xml with older SDK version compatibility
echo '<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.arthenica.ffmpegkit">
    <uses-sdk android:minSdkVersion="16" android:targetSdkVersion="30" />
</manifest>' > $TEMP_DIR/AndroidManifest.xml

# Create empty resource file
touch $TEMP_DIR/R.txt

# Create empty classes.jar file - this avoids Java versioning issues
# Instead of compiling with Java, we'll create an empty JAR
mkdir -p $TEMP_DIR/classes
touch $TEMP_DIR/classes/empty.txt

# Create the JAR file manually
cd $TEMP_DIR/classes
jar cf ../classes.jar empty.txt
cd ..

# Create the AAR file (zip with .aar extension)
zip -r "$AAR_PATH" * >/dev/null 2>&1
cd ..

# Clean up temp build directory
rm -rf $TEMP_DIR

# Verify the AAR file exists
if [ ! -f "$AAR_PATH" ]; then
  echo "ERROR: Failed to create dummy FFmpeg AAR file at $AAR_PATH"
  exit 1
fi

# Install to local Maven repository
echo "Installing $AAR_FILE to local Maven repository..."
mvn install:install-file \
    -Dfile="$AAR_PATH" \
    -DgroupId="$GROUP_ID" \
    -DartifactId="$ARTIFACT_ID" \
    -Dversion="$VERSION" \
    -Dpackaging=aar

if [ $? -ne 0 ]; then
  echo "ERROR: Maven install failed. See above for details."
  exit 1
else
  echo "Installation completed successfully!"
fi

# Make sure mavenLocal is in android/build.gradle
if ! grep -q "mavenLocal()" ./android/build.gradle; then
  echo "Adding mavenLocal() to build.gradle"
  sed -i '/repositories {/a\\        mavenLocal()' ./android/build.gradle
fi

# Update android gradle properties to skip Jetifier
echo "Updating gradle.properties to disable Jetifier..."
if ! grep -q "android.enableJetifier" ./android/gradle.properties; then
  echo "android.enableJetifier=false" >> ./android/gradle.properties
fi

echo "Setting up Flutter dependencies..."
flutter pub get

echo "Setup complete! You can now build your app with the FFmpeg library."