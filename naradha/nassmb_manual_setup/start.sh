#!/bin/bash

USERNAMES=("user1" "user2")
PASSWORDS=("password1" "password2")
SHARE_DIRS=("path/to/share1/dir" "path/to/share2/dir" )

if ! getent group sambashare > /dev/null; then
    echo "Creating group 'sambashare'..."
     groupadd sambashare || { echo "Error: Failed to create group 'sambashare'. Exiting."; exit 1; }
fi

for i in "${!USERNAMES[@]}"; do
    USERNAME="${USERNAMES[$i]}"
    PASSWORD="${PASSWORDS[$i]}"

    if id "$USERNAME" &>/dev/null; then
        :
    else
        echo "Adding user '$USERNAME'..."
         useradd "$USERNAME" || { echo "Error: Failed to add user '$USERNAME'. Skipping Samba setup."; continue; }
    fi

    printf "%s\n%s\n" "$PASSWORD" "$PASSWORD" |  smbpasswd -a "$USERNAME" || { echo "Error: Failed to set Samba password for '$USERNAME'."; }

     usermod -aG sambashare "$USERNAME" || { echo "Error: Failed to add user '$USERNAME' to 'sambashare' group."; }
done

for DIR_PATH in "${SHARE_DIRS[@]}"; do
    if [ -d "$DIR_PATH" ]; then
         chown nobody:sambashare "$DIR_PATH" || { echo "Error: Failed to set ownership for '$DIR_PATH'."; }
         chmod 2775 "$DIR_PATH" || { echo "Error: Failed to set permissions for '$DIR_PATH'."; }
    else
        echo "Warning: Directory '$DIR_PATH' not found."
    fi
done

exec  bash -c "/usr/sbin/nmbd --foreground & /usr/sbin/smbd --foreground & wait -n"
