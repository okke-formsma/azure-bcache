#!/bin/bash
# This script installs bcache on an already running elasticsearch node.
# All data on the node will be destroyed!
# part 1

set -e

# change cloud-init config to not mount ephemeral0 to /mnt.
cat >> /etc/cloud/cloud.cfg <<'EOT'
mounts:
- [ ephemeral0 ]
- [ swap, none, swap, sw, '0', '0' ]
- [ /dev/bcache0, /datadisks/disk1, ext4, "nofail,noatime,nodiratime", "0", "0"]
EOT

# undo elasticsearch specific mount
cp /etc/fstab /etc/fstab.old
cat /etc/fstab.old | sed '/datadisks\/disk1/d' > /etc/fstab


# stop elasticsearch
monit stop elasticsearch
sleep 5

# unmount previously mounted disks
umount /mnt
umount /datadisks/disk1

# set up data disk
wipefs -a /dev/sdc1
make-bcache -B /dev/sdc1



