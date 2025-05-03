#!/bin/bash
# Script to install FFmpeg AAR files to local Maven repository

echo "Setting up FFmpeg dependencies..."

# Create directory for AAR files if it doesn't exist
mkdir -p ./android/app/libs

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "Maven not found, installing..."
    apt-get update && apt-get install -y maven
fi

# Define AAR file details
AAR_FILE="ffmpeg-kit-https-6.0-2.LTS.aar"
AAR_PATH="./android/app/libs/$AAR_FILE"

# Check if AAR file exists, download if not
if [ ! -f "$AAR_PATH" ]; then
    echo "Downloading $AAR_FILE..."
    
    # You'll need to provide the download URL for the AAR file
    # For example, you might host it on GitHub releases, your own server, etc.
    # wget -O "$AAR_PATH" "https://your-server.com/path/to/$AAR_FILE"
    
    echo "NOTE: Please manually place the $AAR_FILE in $AAR_PATH or update this script with a valid download URL"
fi

# Check if file exists now (either it was already there or was downloaded)
if [ -f "$AAR_PATH" ]; then
    echo "Installing $AAR_FILE to local Maven repository..."
    
    # Install the AAR to local Maven repository
    mvn install:install-file \
      -Dfile="$AAR_PATH" \
      -DgroupId=com.arthenica \
      -DartifactId=ffmpeg-kit-https \
      -Dversion=6.0-2.LTS \
      -Dpackaging=aar
      
    echo "Installation completed successfully!"
else
    echo "ERROR: $AAR_FILE not found at $AAR_PATH"
    echo "Please manually download the file and place it in the specified location."
    exit 1
fi

echo "Setting up Flutter dependencies..."
flutter pub get

echo "Setup complete! You can now build your app."