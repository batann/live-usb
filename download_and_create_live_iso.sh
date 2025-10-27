#!/bin/bash
# vim:fileencoding=utf-8:foldmethod=marker



#{{{ >>>    dead code
dead_code() (
set -euo pipefail

declare -A ISO_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso/download"
)

declare -A SHA256_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso.sha256"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256/download"
)


declare -A ISO_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso/download"
  [mx]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso"
  [parrot]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso"
  [kali]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso"
)

declare -A SHA_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso.sha256"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256/download"
  [mx]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso.sha256"
  [parrot]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso.sha256"
  [kali]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso.sha256"
)

format_usb_ext4() {
printf "d\no\nn\np\n\n\ny\nw\n" | sudo fdisk /dev/sdc
printf "y\n"|sudo mkfs.ext4 -L "$USB" /dev/sdc1
}

format_usb_vfat() {
printf "d\no\nn\np\n\n\ny\nt\nL\n0c\nw\n" | sudo fdisk /dev/sdc
printf "y\n"|sudo mkfs.vfat -F32 -n "$USB" /dev/sdc1
}

TMPDIR="/home/ISO"
if [[ ! -d $TMPDIR ]]; then
  mkdir -p $TMPDIR
fi

# -- Menu
echo -e "\033[32m"
tput cup 3 26
echo -e "Select OS to write\033[36m:\033[37m"
select os in "alpine" "debian" "antix" "mx" "parrot" "kali" ; do
  [[ -n "$os" ]] && break
done

iso_url="${ISO_URLS[$os]}"
sha_url="${SHA256_URLS[$os]}"
iso_file="$TMPDIR/${iso_url##*/}"

echo -e "\n>> Downloading ISO..."
curl -L "$iso_url" -o "$iso_file"

echo ">> Downloading SHA256..."
sha_file="$TMPDIR/${sha_url##*/}"
curl -L "$sha_url" -o "$sha_file"

echo ">> Verifying checksum..."
pushd "$TMPDIR" >/dev/null
if [[ "$os" == "debian" ]]; then
  grep "$(basename "$iso_file")" "$sha_file" | sha256sum -c -
else
  sha256sum -c "$sha_file"
fi
popd >/dev/null

# -- USB device selection
echo -e "\nAvailable block devices:"
lsblk -dpno NAME,SIZE,MODEL | grep -v "$(findmnt -n / | cut -d' ' -f1 | sed 's/[0-9]*$//')"

read -rp $'\nEnter space-separated target USB devices (e.g., /dev/sdX /dev/sdY): ' -a targets

echo -e "\nAbout to write ISO to:\n${targets[*]}"
read -rp "Are you sure? This will wipe them. Type 'yes': " confirm
[[ "$confirm" != "yes" ]] && echo "Aborted." && exit 1

# -- Write to each device
for dev in "${targets[@]}"; do
  echo -e "\n>> Writing to $dev"
  sudo dd if="$iso_file" of="$dev" bs=4M status=progress oflag=sync
done

sync
echo -e "\n✅ All done. You may now boot from the USB(s)."

}
#}}}
clear
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m┌───────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[0;36;40m  To install one of the following linux distributions:     \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m1\033[0;34;40m) \033[0;35;40m Parrot OS                             \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m2\033[0;34;40m) \033[0;35;40m Kali OS                               \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m3\033[0;34;40m) \033[0;35;40m AntiX                                 \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m4\033[0;34;40m) \033[0;35;40m AntiX Core                            \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m5\033[0;34;40m) \033[0;35;40m Kodachi OS                            \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[36;40m           \033[1;31;40m>>>   \033[0;37;40m6\033[0;34;40m) \033[0;35;40m Tails OS                              \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[0;36;40m  you will need a usb and a working internet connection.   \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[0;36;40m  Please ensure that you are \033[5;92;100mconnect\033[0;36;40med \033[5;92;100mto the internet\033[0;36;40m     \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[0;36;40m  and \033[5;92;100mplugin\033[0;36;40m the \033[5;92;100musb\033[0;36;40m device.                               \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m│\033[0;36;40m          Then press \033[0;1;31;40m[[\033[0;36;40m ANY \033[1;31;40m]]\033[0;36;40m to continue...              \033[0;1;33m│\033[0m"
echo -e "\033[$(( $(( $(tput cols) - 63 )) / 3 ))G\033[1;33m└───────────────────────────────────────────────────────────┘\033[0m"
    read -n1 LOL
    clear
KKK=$(( $(( $(tput cols) - 63 )) / 3 ))
echo -e "\033[${KKK}G\033[92;100mSelect a Distribution\033[0m"
echo -e "\033[2A"

#{{{ >>>   trap
        tput civis  # Hide cursor
trap 'tput cnorm' EXIT
#}}}
#{{{ >>>   yesandno  >#903
yesandno() {
    ABC="$1"
    # Define options and corresponding commands
    OPTIONS=("parrot os" "kali os" "antix net" "antix core" "kodachi os")
    LINK=("https://bunny.deb.parrot.sh//parrot/iso/6.4/Parrot-home-6.4_amd64.iso"
        "https://kali.download/base-images/kali-2025.3/kali-linux-2025.3-installer-amd64.iso"
        "https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/antiX-23.2-net_x64-net.iso/download"
        "https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/antiX-23.2_x64-core.iso/download"
"https://ixpeering.dl.sourceforge.net/project/linuxkodachi/kodachi-8.27-64-kernel-6.2.iso?viasf=1")
    NUM_OPTIONS=${#OPTIONS[@]}


        # Function to display options horizontally
        DISPLAY_OPTIONS() {
            echo -e "\033[G"  # Move cursor to beginning of the line
            for ((i=0; i<NUM_OPTIONS; i++)); do
                if [[ $i -eq $selected ]]; then
                    echo -e "\033[${KKK}G\e[0;1;37;44m${OPTIONS[i]}\033[0m"  # Highlight selected option
                else
                    echo -e "\033[${KKK}G\033[0;1;37m${OPTIONS[i]}\033[0m"
                fi
            done
                echo -e "\033[${NUM_OPTIONS}A"
        }
    # Function to execute selected command
    EXECUTE_COMMAND() {
        wget ${LINK[selected]}
    

    #    eval "${COMMANDS[selected]}"
        return 0

    }

selected=0
DISPLAY_OPTIONS

# Main loop
while true; do
    IFS= read -rsn1 key
    if [[ $key == $'\e' ]]; then
        read -rsn2 key  # Read next two characters
        case $key in
            '[A')  ((selected--)) ;;  # Left
            '[B')  ((selected++)) ;;  # Right
        esac
    elif [[ $key == "" ]]; then
        EXECUTE_COMMAND
        break
    fi

    ((selected = (selected + NUM_OPTIONS) % NUM_OPTIONS))
    echo -e "\033[3A"
    DISPLAY_OPTIONS
done


tput cnorm  # Restore cursor visibility
}
yesandno $@
