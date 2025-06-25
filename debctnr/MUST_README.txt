# IMPORTANT
`share_conf.txt` contains the template for `smb.conf` located in `/etc/samba/`, modify the template as required and copy it to `configs` directory so that it can be used to overwrite the actual `/etc/samba/smb.conf` using `>>` in the container. Also, make sure th directories configured in the `smb.conf` exist in the nas directory.

# Creating the image and the container:
Just run the `create_image.sh` file and then the `start.sh <container_name>`. Now you can enter the shell of the container by using `connect.sh <container_name>` and setup the shares.

# Setting up the shares inside the container:
1. Add users with this
    `sudo useradd username`
    `sudo smbpasswd -a username`

2. Add users to smbshare group
    `sudo groupadd sambashare`
    `sudo usermod -aG sambashare user`

3. Give permissions to share directories 
    `sudo chown nobody:sambashare /app/nas/share_name`
    `sudo chmod 2775 /app/nas/share_name`

Command to create container
docker run -it --name smb_server -p 139:139 -p 445:445 -v ./nas/:/app/nas/ -v ./configs/:/app/config/ mysmb

THE ./config containing the config of the required shares must be mounted to /app/config/and the dirs for shares must be created.
