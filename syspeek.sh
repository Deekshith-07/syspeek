#!/bin/bash

# Define the file paths for the reports
TEXT_REPORT="/home/deekshith/Desktop/report.txt"
CSV_REPORT="/home/deekshith/Desktop/report.csv"
HTML_REPORT="/home/$hostname/Desktop/report.html"

# Ensure wmctrl is installed
if ! command -v wmctrl &> /dev/null
then
    echo -e "\033[0;31mwmctrl could not be found, please install it using: sudo apt install wmctrl\033[0m"
    exit
fi

# Get system information
HOSTNAME=$(hostname)
USER=$(whoami)
OS=$(lsb_release -d | awk -F"\t" '{print $2}')
KERNEL=$(uname -r)
UPTIME=$(uptime -p)
SHELL=$(echo $SHELL)
CPU=$(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^[ \t]*//')
GPU=$(lspci | grep -E "VGA|3D" | awk -F: '{print $3}' | sed 's/^[ \t]*//')
MEMORY_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEMORY_USED=$(free -h | grep Mem | awk '{print $3}')
PACKAGES=$(dpkg --list | wc -l)
RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
DE=$(echo $XDG_CURRENT_DESKTOP)
WM=$(wmctrl -m | grep Name | awk '{print $2}')
WM_THEME=$(gsettings get org.gnome.desktop.wm.preferences theme | tr -d "'")
GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
ICONS=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
TERMINAL=$(echo $TERM)

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
RESET="\033[0m"

# Create ASCII Art Logo
ASCII_LOGO=$(cat <<'EOF'


 .d8888b.                    8888888b.                   888      
d88P  Y88b                   888   Y88b                  888      
Y88b.                        888    888                  888      
 "Y888b.   888  888 .d8888b  888   d88P .d88b.   .d88b.  888  888 
    "Y88b. 888  888 88K      8888888P" d8P  Y8b d8P  Y8b 888 .88P 
      "888 888  888 "Y8888b. 888       88888888 88888888 888888K  
Y88b  d88P Y88b 888      X88 888       Y8b.     Y8b.     888 "88b 
 "Y8888P"   "Y88888  88888P' 888        "Y8888   "Y8888  888  888 
                888                                               
           Y8b d88P                                               
            "Y88P"                                                
                                                                                                                                      
EOF
) 

# Help message
display_help() {
    echo -e ${CYAN}"$ASCII_LOGO"${RESET}
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
${CYAN}$ASCII_LOGO${RESET}

${GREEN}System Information Report${RESET}
=========================
${RED}Host:${RESET} $HOSTNAME
${RED}User:${RESET} $USER
${RED}OS:${RESET} $OS
${RED}Kernel:${RESET} $KERNEL
${RED}Uptime:${RESET} $UPTIME
${RED}Shell:${RESET} $SHELL
${RED}CPU:${RESET} $CPU
${RED}GPU:${RESET} $GPU
${RED}Memory:${RESET} $MEMORY_USED / $MEMORY_TOTAL
${RED}Packages:${RESET} $PACKAGES
${RED}Resolution:${RESET} $RESOLUTION
${RED}DE:${RESET} $DE
${RED}WM:${RESET} $WM
${RED}WM Theme:${RESET} $WM_THEME
${RED}GTK Theme:${RESET} $GTK_THEME
${RED}Icons:${RESET} $ICONS
${RED}Terminal:${RESET} $TERMINAL
EOF
)

CSV_CONTENT=$(cat <<EOF
Host,User,OS,Kernel,Uptime,Shell,CPU,GPU,Memory,Packages,Resolution,DE,WM,WM Theme,GTK Theme,Icons,Terminal
$HOSTNAME,$USER,$OS,$KERNEL,$UPTIME,$SHELL,$CPU,$GPU,$MEMORY_USED / $MEMORY_TOTAL,$PACKAGES,$RESOLUTION,$DE,$WM,$WM_THEME,$GTK_THEME,$ICONS,$TERMINAL
EOF
)

HTML_CONTENT=$(cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>System Information Report</title>
<style>
body{
  background: -webkit-linear-gradient(left, #25c481, #25b7c4);
  background: linear-gradient(to right, #25c481, #25b7c4);
  font-family: 'Roboto', sans-serif;
}
section{
  margin: 50px;
}
h1{
  font-size: 30px;
  color: #fff;
  text-transform: uppercase;
  font-weight: 300;
  text-align: center;
  margin-bottom: 15px;
}
table{
  width:100%;
  table-layout: fixed;
}
.tbl-header{
  background-color: rgba(255,255,255,0.3);
 }
.tbl-content{
  height:300px;
  overflow-x:auto;
  margin-top: 0px;
  border: 1px solid rgba(255,255,255,0.3);
}
th, td{
  padding: 20px 15px;
  text-align: left;
  font-weight: 500;
  font-size: 12px;
  color: #fff;
  text-transform: uppercase;
  vertical-align: top;
}
th{
  background-color: rgba(255,255,255,0.3);
}
td{
  border-bottom: solid 1px rgba(255,255,255,0.1);
}
.made-with-love {
  margin-top: 40px;
  padding: 10px;
  clear: left;
  text-align: center;
  font-size: 10px;
  font-family: arial;
  color: #fff;
}
.made-with-love i {
  font-style: normal;
  color: #F50057;
  font-size: 14px;
  position: relative;
  top: 2px;
}
.made-with-love a {
  color: #fff;
  text-decoration: none;
}
.made-with-love a:hover {
  text-decoration: underline;
}
::-webkit-scrollbar {
    width: 6px;
} 
::-webkit-scrollbar-track {
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3); 
} 
::-webkit-scrollbar-thumb {
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3); 
}

</style>
</head>
<body>
<section>
  <h1>System Information Report</h1>
  <div class="tbl-content">
    <table cellpadding="0" cellspacing="0" border="0">
      <tbody>
        <tr>
          <th>Host</th>
          <td>$HOSTNAME</td>
        </tr>
        <tr>
          <th>User</th>
          <td>$USER</td>
        </tr>
        <tr>
          <th>OS</th>
          <td>$OS</td>
        </tr>
        <tr>
          <th>Kernel</th>
          <td>$KERNEL</td>
        </tr>
        <tr>
          <th>Uptime</th>
          <td>$UPTIME</td>
        </tr>
        <tr>
          <th>Shell</th>
          <td>$SHELL</td>
        </tr>
        <tr>
          <th>CPU</th>
          <td>$CPU</td>
        </tr>
        <tr>
          <th>GPU</th>
          <td>$GPU</td>
        </tr>
        <tr>
          <th>Memory</th>
          <td>$MEMORY_USED / $MEMORY_TOTAL</td>
        </tr>
        <tr>
          <th>Packages</th>
          <td>$PACKAGES</td>
        </tr>
        <tr>
          <th>Resolution</th>
          <td>$RESOLUTION</td>
        </tr>
        <tr>
          <th>DE</th>
          <td>$DE</td>
        </tr>
        <tr>
          <th>WM</th>
          <td>$WM</td>
        </tr>
        <tr>
          <th>WM Theme</th>
          <td>$WM_THEME</td>
        </tr>
        <tr>
          <th>GTK Theme</th>
          <td>$GTK_THEME</td>
        </tr>
        <tr>
          <th>Icons</th>
          <td>$ICONS</td>
        </tr>
        <tr>
          <th>Terminal</th>
          <td>$TERMINAL</td>
        </tr>
      </tbody>
    </table>
  </div>
</section>
<div class="made-with-love">
  Made with <i>♥</i> by <a target="_blank" href="https://codepen.io/nikhil8krishnan">Nikhil Krishnan</a>
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
    *)
        # Print the information to the terminal
        echo -e "$TEXT_CONTENT"
        ;;
esac
