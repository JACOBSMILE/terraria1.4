#!/bin/bash
pipe=/tmp/terraria.pipe

# Check Config
if [[ "$TERRARIA_USECONFIGFILE" == "Yes" ]]; then
  if [ -e /root/terraria-server/serverconfig.txt ]; then
    echo -e "Terraria server will launch with the supplied config file."
  else
    echo -e "[!!] ERROR: The Terraria server was set to launch with a config file, but it was not found. Please map the file and launch the server again."
    sleep 5s
    exit 1
  fi
else
# Print Env variables
  echo -e "Shutdown Message set to: $TERRARIA_SHUTDOWN_MESSAGE"
  echo -e "Save Interval set to: $TERRARIA_AUTOSAVE_INTERVAL minutes"
  echo -e "World Name set to: $TERRARIA_WORLDNAME"
  echo -e "World Size set to: $TERRARIA_WORLDSIZE"
  echo -e "World Seed set to: $TERRARIA_WORLDSEED"
  echo -e "Max Players set to: $TERRARIA_MAXPLAYERS"
  echo -e "Server Password set to: $TERRARIA_PASS"
  echo -e "MOTD Set to: $TERRARIA_MOTD"
fi

# Trapped Shutdown, to cleanly shutdown
function shutdown () {
  inject "say $TERRARIA_SHUTDOWN_MESSAGE"
  sleep 3s
  inject "exit"
  tmuxPid=$(pgrep tmux)
  terrPid=$(pgrep --parent $tmuxPid Main)
  while [ -e /proc/$terrPid ]; do
    sleep .5
  done
  rm $pipe
}

# Base startup command
TERRARIA_PATH=$(ls -d /root/terraria-server/*|head -n 1)
server="$TERRARIA_PATH/Linux/TerrariaServer.bin.x86_64 -server"

# If config, we supply it at the command line.
if [[ "$TERRARIA_USECONFIGFILE" == "Yes" ]]; then
  server="$server -config /root/terraria-server/config.txt"

else
  # Check if the world file exists.
  if [ -e "/root/.local/share/Terraria/Worlds/$TERRARIA_WORLDNAME.wld" ]; then
    server="$server -world \"/root/.local/share/Terraria/Worlds/$TERRARIA_WORLDNAME.wld\""
  else
  # If it does not, alert the player, and set the startup parameters to automatically generate the world.
    echo -e "[!!] WARNING: The world \"$TERRARIA_WORLDNAME\" was not found. The server will automatically create a new world."
    sleep 3s
    server="$server -world \"/root/.local/share/Terraria/Worlds/$TERRARIA_WORLDNAME.wld\""
    server="$server -autocreate $TERRARIA_WORLDSIZE -worldname \"$TERRARIA_WORLDNAME\" -seed \"$TERRARIA_WORLDSEED\""
  fi

  server="$server -players $TERRARIA_MAXPLAYERS"

  if [[ "$TERRARIA_PASS" == "N/A" ]]; then
    echo -e "[!!] Server Password has been disabled."
  else
    server="$server -pass \"$TERRARIA_PASS\""
  fi

  server="$server -motd \"$TERRARIA_MOTD\""
fi

# Trap the shutdown
trap shutdown TERM INT
echo -e "Terraria Server is launching with the following command:"
echo -e $server

# Create the tmux and pipe, so we can inject commands from 'docker exec [container id] inject [command]' on the host
sleep 5s
mkfifo $pipe
tmux new-session -d "$server | tee $pipe"

# Call the autosaver
/root/terraria-server/autosave.sh &

# Infinitely print the contents of the pipe, so the container still logs the Terraria Server.
cat $pipe &
wait ${!}