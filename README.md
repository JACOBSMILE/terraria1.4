# Terraria Server Powered By Docker
![Auto-Update Badge](https://github.com/JACOBSMILE/terraria1.4/actions/workflows/terraria-check.yml/badge.svg)

[View on Github](https://github.com/JACOBSMILE/terraria1.4) |
[View on Dockerhub](https://registry.hub.docker.com/r/jacobsmile/terraria1.4)

This Docker Image is designed to allow for easy configuration and setup of a Terraria server.

## Features
- Scheduled World Saving
- Graceful Shutdowns
- Configuration Files are optional
- Github Automation to stay up-to-date with Terraria's release cycle

## Credits & Mentions
- Terraria
  - [Website](https://terraria.org/)
  - [Steam Store Page](https://store.steampowered.com/app/105600/Terraria/)

## Check out all of my Terraria Images!

1.4 Vanilla Terraria: [Github](https://github.com/JACOBSMILE/terraria1.4) | [Dockerhub](https://registry.hub.docker.com/r/jacobsmile/tmodloader1.4)

1.4 tModLoader: [Github](https://github.com/JACOBSMILE/tmodloader1.4) | [Dockerhub]()

# Repository Automation & Daily Automated Builds
The Github repository has been configured with an automated workflow to check for Terraria updates daily and update the latest image and Dockerfile with the new Terraria version. 

Additionally, the Dockerhub registry will maintain all previous versions which are processed through this automated workflow. You can access these previous versions by pulling a repository with the Terraria version string as the tag, ignoring the periods. For example, version 1.4.4.9 will be tag `jacobsmile/terraria1.4:1449`.

## To Pull the Latest Terraria Server Image

```bash
# ":latest" will pull the most recent Terraria version
docker pull jacobsmile/terraria1.4:latest
```

## To Pull a Specific Terraria Server Image Version
```bash
# Replace '1449' with the intended version number of Terraria you wish to run. For example, version 1.4.4.9 will be tag 1449.
docker pull jacobsmile/terraria1.4:1449
```

# Container Preparation

### World Directory (Required for Persistent Worlds)
Create a directory on Host machine to house the world file as well as backups.
```bash
# Making the Worlds directory and exporting it to a variable.
mkdir /path/to/worlds/directory
export TERRARIA_WORLDS=/path/to/worlds/directory
```
_You can omit this, though the worlds will not be saved after your container shuts down! You have been warned._

---

### Server Configuration File (Optional)
If you would rather have the server read from a configuration file, you may map the configuration file directly. Be sure to set the `TERRARIA_USECONFIGFILE` environment variable to a value of `YES`.

Refer to the [Terraria Server Documentation]((https://terraria.fandom.com/wiki/Server#Server_config_file)) on how to setup a configuration file.

```bash
# Exporting the path to the config.txt to a variable
export TERRARIA_CONFIGFILE=/path/to/config.txt
```
---

# Environment Variables
The following are all of the environment variables that are supported by the container.

| Variable      | Default Value | Description |
| ----------- | ----------- | ----------- |
| TERRARIA_SHUTDOWN_MESSAGE | Server is shutting down NOW! | The message which will be sent to the in-game chat upon container shutdown.
| TERRARIA_AUTOSAVE_INTERVAL   | 10 | The autosave interval (in minutes) in which the World will be saved.
| TERRARIA_MOTD |  Terraria server powered by Docker! (https://github.com/JACOBSMILE/terraria1.4) You can change this message with the TERRARIA_MOTD environment variable. | The Message of the Day which prints in the chat upon joining the server.
| TERRARIA_PASS | docker | The password players must supply to join the server. Set this variable to "N/A" to disable requiring a password on join. (Not Recommended)
| TERRARIA_MAXPLAYERS | 8 | The maximum number of players which can join the server at once.
| TERRARIA_WORLDNAME | Docker | The name of the world file. This is seen in-game as well as will be used for the name of the .WLD file.
| TERRARIA_WORLDSIZE | 3 | When generating a new world, this variable will be used to designate the size. 1 = Small, 2 = Medium, 3 = Large
| TERRARIA_WORLDSEED | Docker | The seed for a new world.
| TERRARIA_USECONFIGFILE | No | If you wish to use a config file  to specify MOTD, Password, Max Players, World Name, World Size, World Seed, and a few other additional settings, set this to "Yes".

# Running the Container

## Docker Command

```bash
# Pull the image
docker pull jacobsmile/terraria1.4:latest

# Execute the container
docker run -p 7777:7777 --name terraria --rm \
  -v $TERRARIA_WORLDS:/root/.local/share/Terraria/Worlds \
  -v $TERRARIA_CONFIGFILE:/root/terraria-server/config.txt \
  -e TERRARIA_SHUTDOWN_MESSAGE='Goodbye!' \
  -e TERRARIA_AUTOSAVE_INTERVAL='15' \
  -e TERRARIA_MOTD='Welcome to my Terraria Server!' \
  -e TERRARIA_PASS='secret' \
  -e TERRARIA_MAXPLAYERS='16' \
  -e TERRARIA_WORLDNAME='Earth' \
  -e TERRARIA_WORLDSIZE='2' \
  -e TERRARIA_WORLDSEED='not the bees!' \
  -e TERRARIA_USECONFIGFILE='No' \
  jacobsmile/terraria1.4
```

## Docker Compose

Included in the Github repository is a sample `docker-compose.yml` file. Refer to the contents of this file to learn how to configure this file. 

Once you are satisfied with the compose file, start it with the following command.
```bash
docker compose up --build
```

# Interacting with the Server

To send commands to the server once it has started, use the following command on your Host machine. The below example will send "Hello World" to the game chat.

```bash
docker exec terraria inject "say Hello World!"
```
You can alernatively use the UID of the container in place of `terraria` if you did not name your configuration.

_Credit to [ldericher](https://github.com/ldericher/tmodloader-docker) for this method of command injection to Terraria's console._

# Notes
I do not own Terraria. This Docker Image was created for players to easily host a game server with Docker, and is not intended to infringe on any Copyright, Trademark or Intellectual Property.