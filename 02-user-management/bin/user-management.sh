#!/bin/bash

# Check username is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# $1 is the argument passed
USERNAME=$1

# Check if user already exists
if grep -q "^$USERNAME:" /etc/passwd; then
    echo "User '$USERNAME' already exists. Exiting gracefully."
    exit 0
fi

# Ensure developers group exists if not create one
if ! grep -q "^developers:" /etc/group; then
    sudo groupadd developers
    echo "Group 'developers' created."
fi

# Generate random password
PASSWORD="Welcome123"

# Create the user and add to developers group
sudo useradd -m -s /bin/bash -G developers "$USERNAME"

# Set generated password
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Force Password change on first login
sudo chage -d 0 "$USERNAME"

# Set home directory permission to 700
sudo chmod 700 /home/$USERNAME

# Validate user creation
if grep -q "^$USERNAME:" /etc/passwd; then
    echo "User '$USERNAME' created successfully."
    echo "Temporary Password: $PASSWORD"
else
    echo "User creation failed."
fi