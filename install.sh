#!/bin/sh
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb

if [ -d ~/ccminer ]
then
  rm -r ~/ccminer  
  mkdir ~/ccminer
fi

GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/CCminer-ARM-optimized/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer
mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
rm ~/ccminer/config.json
wget https://raw.githubusercontent.com/thepiox/android-miner/main/config.json -P ~/ccminer
chmod +x ~/ccminer/ccminer

# Add start.sh
cat << EOF > ~/ccminer/start.sh
#!/bin/sh

#exit existing screens with the name CCminer
screen -S CCminer -X quit 1>/dev/null 2>&1

#wipe any existing (dead) screens)
screen -wipe 1>/dev/null 2>&1

#create new disconnected session CCminer
screen -dmS CCminer 1>/dev/null 2>&1

#run the miner
screen -S CCminer -X stuff "~/ccminer/ccminer -c ~/ccminer/config.json\n" 1>/dev/null 2>&1
printf '\nMining started.\n'
printf '===============\n'
printf '\nManual:\n'
printf 'start: ~/.ccminer/start.sh\n'
printf 'stop: screen -X -S CCminer quit\n'
printf '\nmonitor mining: screen -x CCminer\n'
printf "exit monitor: 'CTRL-a' followed by 'd'\n\n"
EOF

chmod +x ~/ccminer/start.sh

echo "setup completed."
