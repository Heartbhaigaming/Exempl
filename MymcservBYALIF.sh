#!/bin/bash

# Function to display progress animation
function show_progress {
    local msg=$1
    local delay=0.5
    echo -n "$msg"
    while [ "$(jobs | wc -l)" -gt 0 ]; do
        echo -n "."
        sleep $delay
    done
    echo ""
}

# Update and install JDK 21
echo "Updating package lists..."
sudo apt-get update
echo "Installing OpenJDK 21..."
sudo apt-get install -y openjdk-21-jre
show_progress "JDK 21 installation in progress"

# Check Java version
echo "Checking Java version..."
jdk_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [[ "$jdk_version" == "21."* ]]; then
    echo "JDK 21 successfully installed"
else
    echo "JDK installation failed or incorrect version"
    exit 1
fi

# Ask user for server type
echo "Select server type:"
echo "1) Paper"
echo "2) Purpur"
echo "3) Velocity"
read -p "Enter the number corresponding to your choice: " server_type

case $server_type in
    1)
        server_name="Paper"
        server_url="https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/57/downloads/paper-1.21.1-57.jar"
        ;;
    2)
        server_name="Purpur"
        server_url="https://api.purpurmc.org/v2/purpur/1.21.1/2301/download"
        ;;
    3)
        server_name="Velocity"
        server_url="https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/427/downloads/velocity-3.3.0-SNAPSHOT-427.jar"
        ;;
    *)
        echo "Invalid selection"
        exit 1
        ;;
esac

# Download selected server JAR
echo "Downloading $server_name server..."
wget -O minecraft_server.jar $server_url
show_progress "$server_name server download in progress"
echo "$server_name server (version 1.21.1) successfully downloaded"

# Set file permissions
chmod +x minecraft_server.jar

# Run the server to generate configuration files
echo "Running Minecraft server to generate configuration files..."
java -Xmx2G -Xms2G -jar minecraft_server.jar nogui
sleep 10  # Allow time for files to be generated

# Install nano editor
echo "Installing nano editor..."
sudo apt-get install -y nano

# Edit eula.txt
sudo nano eula.txt
echo "eula=true" | sudo tee eula.txt

# Edit server.properties
sudo nano server.properties

# Online players configuration
read -p "Allow online players? (1 for Yes, 2 for No): " online_players
if [[ $online_players -eq 1 ]]; then
    sed -i 's/online-mode=false/online-mode=true/' server.properties
    echo "Online players enabled."
else
    echo "Online players disabled."
fi

# RAM allocation
echo "Select RAM allocation:"
echo "1) Default"
echo "2) 2GB"
echo "3) 4GB"
echo "4) 6GB"
read -p "Enter your choice: " ram_choice

case $ram_choice in
    1)
        ram_allocation=$(free -g | awk '/^Mem:/{print $2 "G"}')
        ;;
    2)
        ram_allocation="2G"
        ;;
    3)
        ram_allocation="4G"
        ;;
    4)
        ram_allocation="6G"
        ;;
    *)
        echo "Invalid selection"
        exit 1
        ;;
esac

echo "RAM allocation set to $ram_allocation."

# Start the Minecraft server with selected RAM
echo "Starting Minecraft server with $ram_allocation..."
java -Xmx$ram_allocation -Xms$ram_allocation -jar minecraft_server.jar nogui

# Sleep for 12 hours
echo "Minecraft server is running. The script will now sleep for 12 hours."
sleep 43200