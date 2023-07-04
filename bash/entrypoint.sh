#!/bin/bash

# Function to install additional packages
install_packages() {
    echo "Installing additional packages: $*"
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" \
    && rm -rf /var/lib/apt/lists/*
}

# Check if additional packages are provided as environment variable
if [ -n "$ADDITIONAL_PACKAGES" ]; then
    # Install the packages using the install_packages function
    install_packages "$ADDITIONAL_PACKAGES"
fi

# Execute the CMD from the Dockerfile as appuser
exec gosu appuser bash "$@"
