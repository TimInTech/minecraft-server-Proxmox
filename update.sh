#!/bin/bash

# Change to Minecraft directory
cd /opt/minecraft || exit 1

# Download latest PaperMC jar (manually specified version/build for now)
wget -O server.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/416/downloads/paper-1.20.4-416.jar

echo "✅ Update complete. Restart the server if needed."
