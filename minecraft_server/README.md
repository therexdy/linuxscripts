# Step 1
Download the server.jar file of required version and move it to the ./server/ dir.

# Step 2
Inside the ./server/ dir run the init_run.sh script, once it's started, stop it by typing stop and pressing enter.

# Step 3 
Make sure the eula.txt is set to true in ./server/eula.txt and you can make changes to the ./server/server.properties if you want.

# Step 4
In the ./ dir run `docker compose up -d`.

# Step 5
Edit the systemd file, copy it to ~/.config/systemd/user and enable it.
