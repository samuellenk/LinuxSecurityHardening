#!/usr/bin/env bash
#=====================================================================
#  Marketing share with ACLs – idempotent, self‑cleaning script
#=====================================================================
#  What it does (in order)
#    1  Install the `acl` package if it is missing.
#    2  Create two groups: marketing (regular) and marketing_admin (full‑access).
#    3  Add the requested users to those groups.
#    4  Create /srv/marketing_share, set ownership, set‑gid and basic mode.
#    5  **Remove any existing ACLs** on the directory (clean slate).
#    6  Write a fresh ACL file that contains *exactly* the entries we want.
#    7  Apply that ACL file (both access and default entries).
#    8  Show the final result with `getfacl`.
#
#  Run it as root (or with sudo):
#    sudo ./set_facl.sh
#=====================================================================

set -euo pipefail                     # stop on errors, undefined vars are fatal

#######################################
# Helper functions
#######################################
log()   { echo -e "\e[1;34m[+] $*\e[0m"; }
error() { echo -e "\e[1;31m[-] $*\e[0m" >&2; exit 1; }

#######################################
# 0 USER LIST – edit these arrays
#######################################
# Regular users: r‑x only
MARKETING_USERS=(
  bob sarah carl
)

# Admin users: rwx
ADMIN_USERS=(
  emma
)

USERS=( "${MARKETING_USERS[@]}" "${ADMIN_USERS[@]}" )
for u in "${USERS[@]}"; do
if sudo adduser "$u" &>/dev/null; then
    log "user '$u' created"
  else
    log "user '$u' already exists"
  fi
done

#######################################
# 1 Ensure the ACL package is installed
#######################################
log "Checking for the 'acl' package..."
if rpm -q acl &>/dev/null; then
    log "'acl' is already installed."
else
    log "'acl' not found – installing now."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y acl
    elif command -v yum &>/dev/null; then
        sudo yum install -y acl
    else
        error "Package manager dnf/yum not found – cannot install 'acl'."
    fi
fi

#######################################
# 2 Create groups (if missing)
#######################################
GROUP_MARKETING="marketing"
GROUP_ADMIN="marketing_admin"

for grp in "$GROUP_MARKETING" "$GROUP_ADMIN"; do
    if getent group "$grp" >/dev/null; then
        log "Group '$grp' already exists."
    else
        log "Creating group '$grp'..."
        sudo groupadd "$grp"
    fi
done

#######################################
# 3 Add members to the groups
#######################################
log "Adding regular users to group '$GROUP_MARKETING'..."
for u in "${MARKETING_USERS[@]}"; do
    [[ -z "$u" ]] && continue
    if id "$u" &>/dev/null; then
        sudo usermod -a -G "$GROUP_MARKETING" "$u"
        log "  → $u added to $GROUP_MARKETING"
    else
        error "User '$u' does not exist on this system."
    fi
done

log "Adding admin users to group '$GROUP_ADMIN'..."
for u in "${ADMIN_USERS[@]}"; do
    [[ -z "$u" ]] && continue
    if id "$u" &>/dev/null; then
        sudo usermod -a -G "$GROUP_ADMIN" "$u"
        log "  → $u added to $GROUP_ADMIN"
    else
        error "User '$u' does not exist on this system."
    fi
done

#######################################
# 4 Create the share directory
#######################################
SHARE_DIR="/srv/marketing_share"

log "Ensuring share directory exists at $SHARE_DIR"
sudo mkdir -p "$SHARE_DIR"

# Owner = root, group = marketing (the regular group)
log "Setting ownership to root:$GROUP_MARKETING"
sudo chown root:"$GROUP_MARKETING" "$SHARE_DIR"

# Permissions: 2770 (set‑gid + rwx for owner & group)
log "Applying mode 2750 (set‑gid + rwxr-x for owner & group)"
sudo chmod 2750 "$SHARE_DIR"

#######################################
# 5 ***Wipe existing ACLs*** – start clean
#######################################
log "Removing any existing ACLs on $SHARE_DIR (both access & default)"
sudo setfacl -R -b "$SHARE_DIR"

#######################################
# 6 Build temporary ACL file with ONLY the desired entries
#######################################
TMP_ACL_FILE=$(mktemp /tmp/marketing_share_acl.XXXXXX)
log "Generating ACL spec file at $TMP_ACL_FILE"

# ----- Access ACL entries -----
{
    echo "# User owner (root) – full rights"
    echo "user::rwx"
    echo "group:${GROUP_ADMIN}:rwx"
    echo "group:${GROUP_MARKETING}:r-x"
    echo "mask::rwx"
    echo "other::---"
} > "$TMP_ACL_FILE"

# ----- Default ACL entries (for future files/dirs) -----
{
    echo ""
    echo "# Default ACLs – will be inherited by everything created inside"
    echo "default:user::r-x"

    echo "default:group:${GROUP_ADMIN}:rwx"
    echo "default:group:${GROUP_MARKETING}:r-x"
    echo "default:mask::rwx"
    echo "default:other::---"
} >> "$TMP_ACL_FILE"

log "ACL spec file contents:"
cat "$TMP_ACL_FILE"

#######################################
# 7 Apply clean ACL file
#######################################
log "Applying the clean ACL spec to $SHARE_DIR"
sudo setfacl -M "$TMP_ACL_FILE" "$SHARE_DIR"

rm -f "$TMP_ACL_FILE"

#######################################
# 8 Show final ACL layout
#######################################
log "Final ACL view for $SHARE_DIR"
getfacl -pc "$SHARE_DIR"

log "All done! 🎉"
log " • regular marketing users (group $GROUP_MARKETING) → r-x"
log " • admin users (group $GROUP_ADMIN) → rwx"
log " • new files/dirs inside inherit exactly the same ACLs"
