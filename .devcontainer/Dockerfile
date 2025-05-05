FROM joshxt/flutterbuilder:latest

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspaces

# Ensure Flutter SDK is on PATH
ENV PATH="/flutter/bin:${PATH}"

# Pre-download dependencies
COPY pubspec.yaml /tmp/
RUN cd /tmp && flutter pub get

# Verify flutter installation and show version
RUN flutter doctor -v

# Switch to non-root user for better security (optional)
# USER vscode