# Kandji EDR Behavioral Attack Simulator
**Platform:** macOS
**Format:** Z shell script

This script will execute several macOS-specific MITRE ATT&CK adversarial behaviors.

Among these behaviors is creating a new hidden file, curling malicious code into it, and executing. Kandji will both block the malicious process, and quarantine the randomly-generated file.
 
Running this script requires elevated privileges (`sudo`), and depending on the terminal program used, you may be prompted to allow access during execution.

---
## Run Attack Script
### 1. Downloading the Script

You can download the script directly using `curl` or `wget` from your terminal, or clone the entire repository:

**Using curl**

```shell
curl -O https://raw.githubusercontent.com/kandji-inc/security-toolkit/main/attack-simulation/edr_test.zsh
```

**Using wget**

```shell
wget https://raw.githubusercontent.com/kandji-inc/security-toolkit/main/attack-simulation/edr_test.zsh
```

**Clone the entire repository**

```shell
git clone https://github.com/kandji-inc/security-toolkit.git
```

### 2. Making the Script Executable

After downloading the script, you'll need to make it executable:

```shell
chmod +x edr_test.zsh
```

### 3. Running the Script

Execute the script with the following command:

```shell
sudo ./edr_test.zsh
```

---
## Considerations

Ensure you have the Z shell installed (`zsh --version`); macOS comes with zsh pre-installed.

Always review scripts downloaded from the internet to understand their behavior before executing, especially when using `sudo`.

*WARNING: Depending on your Avert posture, you may need to remove the generated file yourself. If not in Protect mode, the file will not be quarantined; but merely detected.*
