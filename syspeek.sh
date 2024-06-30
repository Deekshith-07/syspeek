#!/bin/bash

# Define the file paths for the reports
TEXT_REPORT="/home/$USER/Desktop/report.txt"
CSV_REPORT="/home/$USER/Desktop/report.csv"
HTML_REPORT="/home/$USER/Desktop/report.html"

# Ensure wmctrl is installed
if ! command -v wmctrl &> /dev/null; then
    echo -e "\033[0;31mwmctrl could not be found, please install it using: sudo apt install wmctrl\033[0m"
    exit
fi

if ! command -v acpi &> /dev/null; then
    echo -e "\033[0;31macpi could not be found, please install it using: sudo apt install acpi\033[0m"
    exit
fi

if ! command -v sensors &> /dev/null; then
    echo -e "\033[0;31msensors could not be found, please install it using: sudo apt install lm-sensors\033[0m"
    exit
fi

# Get system information
# Fetch HOSTNAME, replace empty with "N/A"
HOSTNAME=$(hostname)
HOSTNAME=${HOSTNAME:-"N/A"}

# Fetch USER, replace empty with "N/A"
USER=$(whoami)
USER=${USER:-"N/A"}

# Fetch OS, replace empty with "N/A"
OS=$(lsb_release -d | awk -F"\t" '{print $2}')
OS=${OS:-"N/A"}

# Fetch KERNEL, replace empty with "N/A"
KERNEL=$(uname -r)
KERNEL=${KERNEL:-"N/A"}

# Fetch UPTIME, replace empty with "N/A"
UPTIME=$(uptime -p)
UPTIME=${UPTIME:-"N/A"}

# Fetch SHELL, replace empty with "N/A"
shell=$(basename "$SHELL")
shell_version=$("$SHELL" --version 2>&1 | head -n 1)

# Determine the appropriate command to get shell version based on the shell type
if [[ "$shell" == "bash" ]]; then
    shell_version=$("$SHELL" --version | head -n 1)
elif [[ "$shell" == "zsh" ]]; then
    shell_version=$("$SHELL" --version | head -n 1)
elif [[ "$shell" == "fish" ]]; then
    shell_version=$("$SHELL" --version | head -n 1)
else
    shell_version=$("$SHELL" --version 2>&1 | head -n 1)
fi

# If version information is not found, fallback to shell path
if [ -z "$shell_version" ]; then
    shell_version=$SHELL
fi

SHELL=${shell_version:-"N/A"}


# Fetch CPU, replace empty with "N/A"
CPU=$(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^[ \t]*//')
CPU=${CPU:-"N/A"}

# Fetch GPU, replace empty with "N/A"
GPU=$(lspci | grep -E "VGA|3D" | awk -F: '{print $3}' | sed 's/^[ \t]*//')
GPU=${GPU:-"N/A"}

# Fetch MEMORY_TOTAL, replace empty with "N/A"
MEMORY_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEMORY_TOTAL=${MEMORY_TOTAL:-"N/A"}

# Fetch MEMORY_USED, replace empty with "N/A"
MEMORY_USED=$(free -h | grep Mem | awk '{print $3}')
MEMORY_USED=${MEMORY_USED:-"N/A"}

# Fetch PACKAGES, replace empty with "N/A"
PACKAGES=$(dpkg --list | wc -l)
PACKAGES=${PACKAGES:-"N/A"}

# Fetch BROKEN_PACKAGES, replace empty with "N/A"
BROKEN_PACKAGES=$(dpkg --audit | wc -l)
BROKEN_PACKAGES=${BROKEN_PACKAGES:-"N/A"}

# Fetch UPGRADABLE_PACKAGES, replace empty with "N/A"
UPGRADABLE_PACKAGES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
UPGRADABLE_PACKAGES=${UPGRADABLE_PACKAGES:-"N/A"}

# Fetch RESOLUTION, replace empty with "N/A"
RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
RESOLUTION=${RESOLUTION:-"N/A"}

# Fetch DE, replace empty with "N/A"
# DE=$(echo $XDG_CURRENT_DESKTOP)
DE=$(gnome-shell --version | awk '{print $1, $3}') 
DE=${DE:-"N/A"}

# Fetch WM, replace empty with "N/A"
WM=$(wmctrl -m | grep Name | awk '{print $2}')
WM=${WM:-"N/A"}

# Fetch WM_THEME, replace empty with "N/A"
WM_THEME=$(gsettings get org.gnome.desktop.wm.preferences theme | tr -d "'")
WM_THEME=${WM_THEME:-"N/A"}

# Fetch GTK_THEME, replace empty with "N/A"
GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
GTK_THEME=${GTK_THEME:-"N/A"}

# Fetch ICONS, replace empty with "N/A"
ICONS=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
ICONS=${ICONS:-"N/A"}

# Fetch TERMINAL, replace empty with "N/A"
TERMINAL=$(echo $TERM)
TERMINAL=${TERMINAL:-"N/A"}


# Get battery information
BATTERY_STATUS=$(acpi -b | awk '{print $3, $4, $5, $6, $7}')
BATTERY_STATUS=${BATTERY_STATUS:-"N/A"}

# Fetch CPU temperature if available
CPU_TEMP=$(sensors | grep -E 'Tctl|Core 0' | awk '{print $2}')
CPU_TEMP=${CPU_TEMP:-"N/A"}

# Fetch GPU temperature if available
GPU_TEMP=$(sensors | grep -E 'edge' | awk '{print $2}')
GPU_TEMP=${GPU_TEMP:-"N/A"}


# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
RESET="\033[0m"
BOLD="\033[1m"

# Create ASCII Art Logo
ASCII_LOGO=$(cat <<'EOF'
    ___               ___               _   
   / __|  _  _   ___ | _ \  ___   ___  | |__
   \__ \ | || | (_-< |  _/ / -_) / -_) | / /
   |___/  \_, | /__/ |_|   \___| \___| |_\_\
          |__/                              

EOF
) 

# Help message
display_help() {
    echo -e ${CYAN}${BOLD}"$ASCII_LOGO"${RESET}
    echo -e "${GREEN}SysPeek - System Information Tool${RESET}"
    echo -e "================================="
    echo -e "${GREEN}Usage:${RESET}"
    echo -e "  syspeek [OPTION]"
    echo -e ""
    echo -e "${GREEN}Options:${RESET}"
    echo -e "  ${YELLOW}--help${RESET}          Display this help message."
    echo -e "  ${YELLOW}--version${RESET}       Display the syspeek version."
    echo -e "  ${YELLOW}--html${RESET}          Generate a system information report in HTML format."
    echo -e "  ${YELLOW}--csv${RESET}           Generate a system information report in CSV format."
    echo -e "  ${YELLOW}--txt${RESET}           Generate a system information report in plain text format."
    echo -e ""
    echo -e "${GREEN}Examples:${RESET}"
    echo -e "  ${RED}syspeek${RESET}                 Display system information in the terminal."
    echo -e "  ${RED}syspeek ${YELLOW}--version${RESET}       Display the syspeek version."
    echo -e "  ${RED}syspeek ${YELLOW}--html${RESET}          Generate an HTML report."
    echo -e "  ${RED}syspeek ${YELLOW}--csv${RESET}           Generate a CSV report."
    echo -e "  ${RED}syspeek ${YELLOW}--txt${RESET}           Generate a plain text report."
    echo -e ""
}

# Create the report content
TEXT_CONTENT=$(cat <<EOF
${CYAN}${BOLD}$ASCII_LOGO${RESET}

${GREEN}System Information Report${RESET}
=========================
${RED}${BOLD}Host:${RESET} $HOSTNAME
${RED}${BOLD}User:${RESET} $USER
${RED}${BOLD}OS:${RESET} $OS
${RED}${BOLD}Kernel:${RESET} $KERNEL
${RED}${BOLD}Uptime:${RESET} $UPTIME
${RED}${BOLD}Shell:${RESET} $SHELL
${RED}${BOLD}CPU:${RESET} $CPU
${RED}${BOLD}GPU:${RESET} $GPU
${RED}${BOLD}Memory:${RESET} $MEMORY_USED / $MEMORY_TOTAL
${RED}${BOLD}Packages:${RESET} $PACKAGES
${RED}${BOLD}Broken Packages:${RESET} $BROKEN_PACKAGES
${RED}${BOLD}Upgradable Packages:${RESET} $UPGRADABLE_PACKAGES
${RED}${BOLD}Resolution:${RESET} $RESOLUTION
${RED}${BOLD}DE:${RESET} $DE
${RED}${BOLD}WM:${RESET} $WM
${RED}${BOLD}WM Theme:${RESET} $WM_THEME
${RED}${BOLD}GTK Theme:${RESET} $GTK_THEME
${RED}${BOLD}Icons:${RESET} $ICONS
${RED}${BOLD}Terminal:${RESET} $TERMINAL
${RED}${BOLD}Battery:${RESET} $BATTERY_STATUS
${RED}${BOLD}CPU Temp:${RESET} $CPU_TEMP
${RED}${BOLD}GPU Temp:${RESET} $GPU_TEMP
EOF
)
BATTERY_STATUS_CLEAN=$(echo "$BATTERY_STATUS" | tr -d ',')
UPTIME_CLEAN=$(echo "$UPTIME" | tr -d ',')
GPU_CLEAN=$(echo "$GPU" | tr -d ',')

CSV_CONTENT=$(cat <<EOF
Host,User,OS,Kernel,Uptime,Shell,CPU,GPU,Memory,Packages,Resolution,DE,WM,WM Theme,GTK Theme,Icons,Terminal,Battery, CPU Temp,GPU Temp
$HOSTNAME,$USER,$OS,$KERNEL,$UPTIME_CLEAN,$SHELL,$CPU,$GPU_CLEAN,$MEMORY_USED / $MEMORY_TOTAL,$PACKAGES,$RESOLUTION,$DE,$WM,$WM_THEME,$GTK_THEME,$ICONS,$TERMINAL,$BATTERY_STATUS_CLEAN,$CPU_TEMP,$GPU_TEMP
EOF
)


HTML_CONTENT=$(cat <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>System Information Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .container {
            width: 80%;
            margin: auto;
            border: 1px solid #ccc;
            border-radius: 5px;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>System Information Report</h1>
        <table>
            <tr><th>Category</th><th>Details</th></tr>
            <tr><td>Host</td><td>$HOSTNAME</td></tr>
            <tr><td>User</td><td>$USER</td></tr>
            <tr><td>OS</td><td>$OS</td></tr>
            <tr><td>Kernel</td><td>$KERNEL</td></tr>
            <tr><td>Uptime</td><td>$UPTIME</td></tr>
            <tr><td>Shell</td><td>$SHELL</td></tr>
            <tr><td>CPU</td><td>$CPU</td></tr>
            <tr><td>GPU</td><td>$GPU</td></tr>
            <tr><td>Memory</td><td>$MEMORY_USED / $MEMORY_TOTAL</td></tr>
            <tr><td>Packages</td><td>$PACKAGES</td></tr>
            <tr><td>Broken Packages</td><td>$BROKEN_PACKAGES</td></tr>
            <tr><td>Upgradable Packages</td><td>$UPGRADABLE_PACKAGES</td></tr>
            <tr><td>Resolution</td><td>$RESOLUTION</td></tr>
            <tr><td>DE</td><td>$DE</td></tr>
            <tr><td>WM</td><td>$WM</td></tr>
            <tr><td>WM Theme</td><td>$WM_THEME</td></tr>
            <tr><td>GTK Theme</td><td>$GTK_THEME</td></tr>
            <tr><td>Icons</td><td>$ICONS</td></tr>
            <tr><td>Terminal</td><td>$TERMINAL</td></tr>
            <tr><td>WiFi</td><td>$WIFI_STATUS</td></tr>
            <tr><td>IP Address</td><td>$IP_ADDRESS</td></tr>
            <tr><td>Battery</td><td>$BATTERY_STATUS</td></tr>
            <tr><td>CPU Temp</td><td>$CPU_TEMP</td></tr>
            <tr><td>GPU Temp</td><td>$GPU_TEMP</td></tr>
        </table>
    </div>
</body>
</html>
EOF
)



# Check the command-line argument and generate the appropriate report
case "$1" in
    --txt)
        echo "$TEXT_CONTENT" > "$TEXT_REPORT"
        echo "Text report generated at $TEXT_REPORT"
        ;;
    --csv)
        echo "$CSV_CONTENT" > "$CSV_REPORT"
        echo "CSV report generated at $CSV_REPORT"
        ;;
    --html)
        echo "$HTML_CONTENT" > "$HTML_REPORT"
        echo "HTML report generated at $HTML_REPORT"
        ;;
    --version)
        echo "syspeek v0.0.1"
        ;;
    --help)
        display_help
        ;;
    "")
        echo -e "$TEXT_CONTENT"
        ;;
    *)
        echo -e "${RED}Error: Invalid option${RESET}\nPlease run 'syspeek --help' to check the available options."
        exit 1
        ;;
esac
