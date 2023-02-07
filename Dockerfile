FROM ubuntu:latest

# The Terraria Game Version, ignoring periods. For example, version 1.4.4.9 will be a value of 1449 in this variable.
ARG TERRARIA_VERSION=1449

# The shutdown message is broadcast to the game chat when the container was stopped from the host.
ENV TERRARIA_SHUTDOWN_MESSAGE="Server is shutting down NOW!"

# The autosave feature will save the world periodically. The interval is in minutes.
ENV TERRARIA_AUTOSAVE_INTERVAL="10"

# The following environment variables will configure common settings for the Terraria server.
ENV TERRARIA_MOTD="A Terraira server powered by Docker!"
ENV TERRARIA_PASS="docker"
ENV TERRARIA_MAXPLAYERS="8"
ENV TERRARIA_WORLDNAME="Docker"
ENV TERRARIA_WORLDSIZE="3"
ENV TERRARIA_WORLDSEED="Docker"

# Loading a configuration file expects a proper Terraria config file to be mapped to /root/terraria-server/serverconfig.txt
# Set this to "Yes" if you would rather use a config file instead of the above settings.
ENV TERRARIA_USECONFIGFILE="No"

EXPOSE 7777

RUN apt-get update
RUN apt-get install -y wget unzip tmux bash

WORKDIR /root/terraria-server
	
RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIA_VERSION}.zip
RUN unzip -o terraria-server-${TERRARIA_VERSION}.zip 
RUN rm terraria-server-${TERRARIA_VERSION}.zip

RUN mkdir -p /root/.local/share/Terraria/Worlds 

COPY entrypoint.sh .
COPY inject.sh /usr/local/bin/inject
COPY autosave.sh .

RUN chmod +x entrypoint.sh /usr/local/bin/inject autosave.sh /root/terraria-server/${TERRARIA_VERSION}/Linux/TerrariaServer.bin.x86_64

ENTRYPOINT ["./entrypoint.sh"]