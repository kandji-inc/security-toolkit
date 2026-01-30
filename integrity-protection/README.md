# Kandji EDR Integrity Protection Test
**Platform:** macOS
**Format:** Z shell script

This script tests integrity protections for Kandji agent files, processes, and configuration. It validates that the EDR properly prevents unauthorized modifications to critical agent components.

The script performs comprehensive tests including file creation/modification/deletion prevention, process signal blocking, mount prevention, and launchctl command blocking on protected Kandji resources.

Running this script requires elevated privileges (`sudo`), and depending on the terminal program used, you may be prompted to allow access during execution.

---
## Run Integrity Protection Test
### 1. Downloading the Script

You can download the script directly using `curl` or `wget` from your terminal, or clone the entire repository:

**Using curl**

```shell
curl -O https://raw.githubusercontent.com/kandji-inc/security-toolkit/main/integrity-protection/edr_integrity_protection.zsh
```

**Using wget**

```shell
wget https://raw.githubusercontent.com/kandji-inc/security-toolkit/main/integrity-protection/edr_integrity_protection.zsh
```

**Clone the entire repository**

```shell
git clone https://github.com/kandji-inc/security-toolkit.git
```

### 2. Making the Script Executable

After downloading the script, you'll need to make it executable:

```shell
chmod +x edr_integrity_protection.zsh
```

### 3. Running the Script

Execute the script with the following command:

```shell
sudo ./edr_integrity_protection.zsh
```

---
## Considerations

Ensure you have the Z shell installed (`zsh --version`); macOS comes with zsh pre-installed.

Always review scripts downloaded from the internet to understand their behavior before executing, especially when using `sudo`.

*NOTE: This script is designed to test EDR protections. All operations should be blocked by the EDR. If any test fails, it indicates a potential gap in EDR protection.*
