# Step 1: make sure the system can run PixelHat, before changing anything.

echo ":: Checking the system..."

# Configs go to the user's home folder, so a normal user must run this.
if [[ $EUID -eq 0 ]]; then
    echo "!! Run this as your normal user, not as root (sudo is asked when needed)." >&2
    USERS="$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65000 { print $1 }')"
    if [[ -z "$USERS" ]]; then
        echo "      No user yet? Create one as root, then log in as it:" >&2
        echo -e "\n          useradd -m -G wheel username" >&2
        echo -e "          passwd username\n" >&2
    else
        echo "      Log in as one of these users: $USERS" >&2
    fi
    exit 1
fi

# Fedora only.
source /etc/os-release
if [[ "${ID:-}" != "fedora" ]]; then
    echo "!! PixelHat needs Fedora (found: ${ID:-unknown})." >&2
    exit 1
fi

# Fedora 43 or newer.
if [[ ! "${VERSION_ID:-}" =~ ^[0-9]+$ ]] || (( VERSION_ID < 43 )); then
    echo "!! PixelHat needs Fedora 43 or newer (found: ${VERSION_ID:-unknown})." >&2
    exit 1
fi

# Hyprland is built for these two architectures only.
ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    echo "!! Unsupported CPU architecture: $ARCH." >&2
    exit 1
fi

# Packages need a few GB of free space on the system disk.
FREE_GB=$(( $(df --output=avail -k / | tail -n 1) / 1024 / 1024))
if (( FREE_GB < 10)); then
    echo "!! Not enough free disk space: ${FREE_GB} GB (need at least 10 GB)." >&2
    exit 1
fi

# dnf and git need the internet.
if ! curl -fsS --max-time 10 -o /dev/null https://fedoraproject.org; then
    echo "!! No internet connection."
    exit 1
fi

# Ask for the password once now, so it does not interrupt the installation later.
if ! sudo -v; then
    echo "!! Sudo is needed to install packages." >&2
    echo "   If $USER can't use sudo, run:" >&2
    echo -e "\n     usermod -aG wheel $USER\n" >&2
    exit 1
fi

echo ":: Fedora $VERSION_ID, $ARCH, ${FREE_GB} GB free: OK"