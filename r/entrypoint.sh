#!/bin/bash

# Function to install additional R packages
install_r_packages() {
    echo "Installing additional R packages: $*"
    Rscript -e "install.packages(c('$*'), repos='https://cloud.r-project.org/')"
}

# Check if additional R packages are provided as environment variable
if [ -n "$ADDITIONAL_R_PACKAGES" ]; then
    # Install the packages using the install_r_packages function
    install_r_packages "$ADDITIONAL_R_PACKAGES"
fi

# Fix permissions for user home after mount
chown -R appuser:appuser /data
chmod -R 777 /data

# Execute the CMD from the Dockerfile
exec Rscript "$@"
