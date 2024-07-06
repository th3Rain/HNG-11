#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" | tee -a /var/log/user_management.log
    exit 1
fi

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <user_list_file>" | tee -a /var/log/user_management.log
    exit 1
fi

USER_LIST_FILE=$1

# Ensure the log directory exists
mkdir -p /var/log
LOG_FILE="/var/log/user_management.log"

# Ensure the secure directory exists
SECURE_DIR="/var/secure"
mkdir -p $SECURE_DIR
chmod 700 $SECURE_DIR
PASSWORD_FILE="$SECURE_DIR/user_passwords.txt"

# Function to create a user and set up their home directory
create_user() {
    local username=$1
    local groups=$2

    # Create personal group
    if ! getent group "$username" > /dev/null 2>&1; then
        groupadd "$username"
        echo "Group $username created" | tee -a $LOG_FILE
    fi

    # Create additional groups if they don't exist
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        if ! getent group "$group" > /dev/null 2>&1; then
            groupadd "$group"
            echo "Group $group created" | tee -a $LOG_FILE
        fi
    done

    # Create the user
    if ! id "$username" > /dev/null 2>&1; then
        useradd -m -g "$username" -G "$groups" "$username"
        echo "User $username created and added to groups $groups" | tee -a $LOG_FILE

        # Generate a random password
        password=$(openssl rand -base64 12)
        echo "$username:$password" | chpasswd
        echo "$username,$password" >> $PASSWORD_FILE

        # Set appropriate permissions and ownership
        chown -R "$username":"$username" "/home/$username"
        chmod 700 "/home/$username"

        echo "Home directory for $username set up with appropriate permissions" | tee -a $LOG_FILE
    else
        echo "User $username already exists" | tee -a $LOG_FILE
    fi

    # Add user to additional groups
    usermod -a -G "$groups" "$username"
}

# Read the user list file
while IFS=';' read -r username groups; do
    # Remove leading and trailing whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs | tr -d ' ')

    if [[ -n "$username" && -n "$groups" ]]; then
        create_user "$username" "$groups"
    fi
done < "$USER_LIST_FILE"

# Set permissions on the password file
chmod 600 $PASSWORD_FILE

echo "User creation process completed" | tee -a $LOG_FILE
