# Step 1
Make changes to the create ./nas dir and ./nas/shareX dirs.

# Step 2
Make changes to smb.conf as per the dirs and also users.

# Step 3 (Optional)
If you want to run the auto setup start.sh script then edit the start.sh too. But, it is recommended to setup the users and permissions manually by referring the script or deleting the contents of the start.sh once the container is setup.

# Step 4
Run `sudo docker compose up`, enter it's tty and do the setup mentioned in Step 3. `sudo` is required because smb uses port 445.

# Step 5
Edit the systemd file, copy it to /etc/systemd/system/ and enable it.
