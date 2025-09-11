## 📋 Quick‑copy‑paste version

```bash
# Verify or install ACL tools
if [ ! -x getfacl ]; then
    sudo dnf install -y acl
fi

# Create groups & members
# normal users:
sudo groupadd marketing
sudo adduser -G marketing susi
sudo adduser -G marketing frank
# admin users:
sudo groupadd marketing_admin
sudo adduser -G marketing_admin alice
sudo adduser -G marketing_admin bob

# Create group folder & ACL
SHARE=/srv/marketing_share
sudo mkdir -p "$SHARE"
sudo chgrp marketing "$SHARE"
sudo chmod 2750 "$SHARE"

sudo setfacl -m g:marketing_admin:rwx "$SHARE"
sudo setfacl -m m::r-x "$SHARE"

# Default ACLs for future folder content
sudo setfacl -d -m g:marketing_admin:rwx "$SHARE"
sudo setfacl -d -m g:marketing:r-x "$SHARE"

# Check result
## show ACL
getfacl -c "$SHARE"
## can marketing only view?
## this shouldn't work as susi:
rm "$SHARE"/file
## can marketing_admin also change?
## this shouldn't work as bob:
rm "$SHARE"/file
touch "$SHARE"/file
```
