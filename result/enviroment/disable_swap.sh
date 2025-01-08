#!/bin/bash

# Function to display messages
function print_message {
    echo -e "\e[32m$1\e[0m"
}

# Disable swap immediately
print_message "Disabling swap immediately..."
sudo swapoff -a
echo "vm.swappiness=0" >> /etc/sysctl.conf

# Remove swap entries from /etc/fstab
print_message "Removing swap entries from /etc/fstab..."
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Verify if swap is disabled
if [ "$(sudo swapon --show)" = "" ]; then
    print_message "Swap is successfully disabled."
else
    echo -e "\e[31mFailed to disable swap. Please check manually.\e[0m"
fi

# Print success message
print_message "Swap has been disabled and will not be enabled on reboot."

sudo sysctl --system

