#!/bin/bash

# Function to install additional Python packages
install_pip_packages() {
    echo "Installing additional Python packages: $*"
    pip install "$*"
}

# Check if additional pip packages are provided as environment variable
if [ -n "$ADDITIONAL_PIP_PACKAGES" ]; then
    # Install the packages using the install_pip_packages function
    install_pip_packages "$ADDITIONAL_PIP_PACKAGES"
fi

# Execute the CMD from the Dockerfile
exec "$@"
