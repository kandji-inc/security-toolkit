#!/bin/zsh

# EDR Integrity Protections Test
# This script tests integrity protections for Kandji agent files and processes
# Run this script directly on the device under test

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to run test and check result
check_operation_blocked() {
    local description="$1"
    local command="$2"

    output=$(/bin/zsh -c "$command" 2>&1)
    exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "${GREEN}✓ PASS${NC}: $description"
        return 0
    else
        echo "${RED}✗ FAIL${NC}: $description"
        echo "  Exit code: $exit_code"
        echo "  Output: $output"
        exit 1
    fi
}

echo "======================================"
echo "EDR Integrity Protection Test"
echo "======================================"
echo ""

# Define protected paths
PROTECTED_KANDJI_LITERALS=(
    "/Library/LaunchDaemons/io.kandji.kandji-daemon.plist"
    "/Library/LaunchDaemons/io.kandji.kandji-library-manager.plist"
    "/Library/LaunchDaemons/io.kandji.kandji-agent.plist"
    "/Library/LaunchAgents/io.kandji.Extension-Manager.plist"
    "/Library/LaunchAgents/io.kandji.Kandji.plist"
)

PROTECTED_KANDJI_DIRECTORIES=(
    "/Library/Kandji"
    "/Library/Application Support/Kandji"
    "/Library/Security/SecurityAgentPlugins/KandjiPassport.bundle"
    "/Applications/Kandji Self Service.app"
    "/Applications/Utilities/Kandji Extension Manager.app"
)

PROTECTED_SYSTEM_DIRECTORIES=(
    "/Library/Application Support"
    "/Applications/Utilities"
    "/Library/LaunchDaemons"
    "/Library/LaunchAgents"
)

PROTECTED_LAUNCH_LABELS=(
    "io.kandji.kandji-daemon"
    "io.kandji.kandji-library-manager"
    "io.kandji.kandji-agent"
    "io.kandji.Extension-Manager"
    "io.kandji.Kandji"
)

ALL_PROTECTED_DIRECTORIES=("${PROTECTED_KANDJI_DIRECTORIES[@]}" "${PROTECTED_SYSTEM_DIRECTORIES[@]}")
ALL_PROTECTED_PATHS=("${PROTECTED_KANDJI_LITERALS[@]}" "${PROTECTED_KANDJI_DIRECTORIES[@]}" "${PROTECTED_SYSTEM_DIRECTORIES[@]}")

# Test 1: File Create Prevention in all protected Kandji directories
echo "Test 1: Testing file create prevention in Kandji directories..."
echo "--------------------------------------"
for directory in "${PROTECTED_KANDJI_DIRECTORIES[@]}"; do
    timestamp=$(/bin/date +%s)
    test_file="${directory}/test_create_${timestamp}.txt"
    check_operation_blocked "Create file in $directory" "sudo /usr/bin/touch \"$test_file\""
done
echo ""

# Test 2: File Open with Write Prevention on all protected Kandji files
echo "Test 2: Testing file open with write prevention on protected Kandji files..."
echo "--------------------------------------"
for filepath in "${PROTECTED_KANDJI_LITERALS[@]}"; do
    check_operation_blocked "Write to $filepath" "sudo /bin/dd if=/dev/zero of=\"$filepath\" bs=1 count=1"
done
echo ""

# Test 3: Hard Link Source Prevention on all Kandji protected files
echo "Test 3: Testing hard link source prevention on all Kandji protected files..."
echo "--------------------------------------"
for filepath in "${PROTECTED_KANDJI_LITERALS[@]}"; do
    timestamp=$(/bin/date +%s)
    link_destination="/tmp/hardlink_to_${timestamp}"
    check_operation_blocked "Create hard link to $filepath" "sudo /bin/ln -f \"$filepath\" \"$link_destination\""
done
echo ""

# Test 4: Hard Link Destination Prevention on all Kandji protected directories
echo "Test 4: Testing hard link destination prevention on all Kandji protected directories..."
echo "--------------------------------------"

link_source="/tmp/hardlink_source_$(/bin/date +%s).txt"
sudo /usr/bin/touch "$link_source" &>/dev/null

for directory in "${PROTECTED_KANDJI_DIRECTORIES[@]}"; do
    timestamp=$(/bin/date +%s)
    link_destination="${directory}/hardlink_${timestamp}"
    check_operation_blocked "Create hard link in $directory" "sudo /bin/ln -f \"$link_source\" \"$link_destination\""
done

/bin/rm -f "$link_source" &>/dev/null
echo ""

# Test 5: File Unlink Prevention on all protected paths
echo "Test 5: Testing file unlink prevention on all protected paths..."
echo "--------------------------------------"
for filepath in "${ALL_PROTECTED_PATHS[@]}"; do
    check_operation_blocked "Delete $filepath" "sudo /bin/rm -rf \"$filepath\""
done
echo ""

# Test 6: File Rename Prevention on all protected paths
echo "Test 6: Testing file rename prevention on all protected paths..."
echo "--------------------------------------"
for path in "${ALL_PROTECTED_PATHS[@]}"; do
    check_operation_blocked "Rename $path" "sudo /bin/mv \"$path\" \"${path}.bak\""
done
echo ""

# Test 7: File Set Mode Prevention on all protected paths
echo "Test 7: Testing file set mode (chmod) prevention on all protected paths..."
echo "--------------------------------------"
for filepath in "${ALL_PROTECTED_PATHS[@]}"; do
    check_operation_blocked "Chmod $filepath" "sudo /bin/chmod 777 \"$filepath\""
done
echo ""

# Test 8: File Set Owner Prevention on all protected paths
echo "Test 8: Testing file set owner (chown) prevention on all protected paths..."
echo "--------------------------------------"
for filepath in "${ALL_PROTECTED_PATHS[@]}"; do
    check_operation_blocked "Chown $filepath" "sudo /usr/sbin/chown nobody \"$filepath\""
done
echo ""

# Test 9: File Set Flags Prevention on all protected paths
echo "Test 9: Testing file set flags (chflags) prevention on all protected paths..."
echo "--------------------------------------"
for filepath in "${ALL_PROTECTED_PATHS[@]}"; do
    check_operation_blocked "Chflags $filepath" "sudo /usr/bin/chflags uchg \"$filepath\""
done
echo ""

# Test 10: Mount Prevention on all protected directories
echo "Test 10: Testing mount prevention on all protected directories..."
echo "--------------------------------------"

timestamp=$(/bin/date +%s)
temp_dmg="/tmp/test_mount_${timestamp}.dmg"
/usr/bin/hdiutil create -size 1m -fs APFS -volname TestVolume "$temp_dmg" &>/dev/null
hdiutil_exit_code=$?

if [ $hdiutil_exit_code -ne 0 ] || [ ! -f "$temp_dmg" ]; then
    echo "${RED}✗ FAIL${NC}: Failed to create test disk image"
    exit 1
fi

for directory in "${ALL_PROTECTED_DIRECTORIES[@]}"; do
    check_operation_blocked "Mount over $directory" "sudo /usr/bin/hdiutil attach \"$temp_dmg\" -mountpoint \"$directory\" -nobrowse"
done

/bin/rm -f "$temp_dmg"
echo ""

# Test 11: Launchctl BLocked Subcommands Prevention on all protected launch labels
echo "Test 11: Testing launchctl blocked subcommands prevention on all protected launch labels..."
echo "--------------------------------------"
LAUNCHCTL_SUBCOMMANDS=("unload" "bootout" "disable" "stop" "kill" "kickstart" "attach" "debug" "remove")
for subcommand in "${LAUNCHCTL_SUBCOMMANDS[@]}"; do
    for label in "${PROTECTED_LAUNCH_LABELS[@]}"; do
        check_operation_blocked "Launchctl $subcommand $label" "sudo /bin/launchctl $subcommand $label"
    done
done
echo ""

# Test 12: Signal Prevention on all Kandji processes
echo "Test 12: Testing signal prevention on all Kandji processes..."
echo "--------------------------------------"
kandji_pids_before=$(/usr/bin/pgrep -i kandji 2>/dev/null || true)

if [ -n "$kandji_pids_before" ]; then
    echo "Found Kandji PIDs: \n$kandji_pids_before"
    BLOCKED_SIGNALS=("HUP" "INT" "QUIT" "ABRT" "KILL" "ALRM" "TERM")

    for signal in "${BLOCKED_SIGNALS[@]}"; do
        for pid in ${=kandji_pids_before}; do
            check_operation_blocked "Send SIG$signal to PID $pid" "sudo /bin/kill -$signal $pid"
        done
    done

    # Test 13: Verify the exact same Kandji processes are still running
    echo ""
    echo "Test 13: Verifying the exact same Kandji processes are still running..."
    echo "--------------------------------------"
    kandji_pids_after=$(/usr/bin/pgrep -i kandji 2>/dev/null || true)
    echo "Found Kandji PIDs: \n$kandji_pids_after"
    
    if [ "$kandji_pids_before" = "$kandji_pids_after" ]; then
        echo "${GREEN}✓ PASS${NC}: All Kandji processes still running with same PIDs"
    else
        echo "${RED}✗ FAIL${NC}: Kandji processes changed"
        exit 1
    fi
else
    echo "${RED}✗ FAIL${NC}: Could not find Kandji process PIDs"
    exit 1
fi
echo ""

echo "${GREEN}All tests passed!${NC}"
exit 0
