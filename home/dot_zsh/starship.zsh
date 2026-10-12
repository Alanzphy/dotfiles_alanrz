# Find out which distribution we are running on.
if [[ -r /etc/os-release ]]; then
  _distro=$(awk -F= '$1 == "ID" { gsub(/"/, "", $2); print tolower($2); exit }' /etc/os-release)
  _distro_like=$(awk -F= '$1 == "ID_LIKE" { gsub(/"/, "", $2); print tolower($2); exit }' /etc/os-release)
elif [[ -r /System/Library/CoreServices/SystemVersion.plist ]]; then
  _distro="macos"
fi

# Set an icon based on the distribution.
# Make sure your font supports these symbols.
case "$_distro" in
    omarchy|arch|archcraft|endeavouros) ICON=" ";;
    kali*)                              ICON=" ";;
    debian*)                            ICON=" ";;
    raspbian*)                          ICON=" ";;
    ubuntu*)                            ICON=" ";;
    elementary*)                        ICON=" ";;
    fedora*)                            ICON=" ";;
    coreos*)                            ICON=" ";;
    gentoo*)                            ICON=" ";;
    mageia*)                            ICON=" ";;
    centos*)                            ICON=" ";;
    opensuse*|tumbleweed*)              ICON=" ";;
    sabayon*)                           ICON=" ";;
    slackware*)                         ICON=" ";;
    linuxmint*)                         ICON=" ";;
    alpine*)                            ICON=" ";;
    aosc*)                              ICON=" ";;
    nixos*)                             ICON=" ";;
    devuan*)                            ICON=" ";;
    manjaro*)                           ICON=" ";;
    rhel*|redhat*)                      ICON=" ";;
    macos*)                             ICON="󰀵 ";;
    *)
      case "$_distro_like" in
        *arch*)                         ICON=" ";;
        *debian*)                       ICON=" ";;
        *rhel*)                         ICON=" ";;
        *)                              ICON=" ";;
      esac
      ;;
esac

export STARSHIP_DISTRO="$ICON"
unset _distro _distro_like
