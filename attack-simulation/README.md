# Kandji EDR Behavioral Attack Simulator
**Platform:** MacOS
**Format:** zsh shell script

*This script will execute several MacOS-specific MITRE ATT&CK adversarial behaviors.

Among these behaviors is creating a new hidden file, curling malicious code into it, and executing. Kandji will both block the malicious process, and quarantine the randomly-generated file.
 
Running this script requires elevated privileges (sudo), and depending on which Terminal program used, you may be prompted to allow access during execution.*

---
## Run Attack Script
1. Downloading the Script

You can download the script directly using curl or wget from your terminal, or clone the entire repository:

### Using curl
```curl -O https://raw.githubusercontent.com/yourusername/your-repo/main/edr_test.sh```

### Using wget
```wget https://raw.githubusercontent.com/yourusername/your-repo/main/edr_test.sh```

### Clone the entire repository

```git clone https://github.com/yourusername/your-repo.git```

2. Making the Script Executable

After downloading the script, you'll need to make it executable:

```chmod +x edr_test.sh```

3. Running the Script

Execute the script with the following command:

```sudo ./edr_test.sh```

---
## Considerations

Ensure you have the Zsh shell installed (zsh --version). Most macOS systems come with Zsh pre-installed.

Always review scripts downloaded from the internet to understand their behavior before executing, especially when using sudo.

*WARNING: Depending on your Avert posture, you may need to remove the generated file yourself. If not in Protect mode, the file will not be quarantined; but merely detected.*