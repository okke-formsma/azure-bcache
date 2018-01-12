#!/bin/bash
# This script installs bcache on an already running elasticsearch node.
# All data on the node will be destroyed!

set -e

# change cloud-init config to not mount ephemeral0 to /mnt.
bash -c 'cat >> /etc/cloud/cloud.cfg' <<'EOT'
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
sleep 1

# unmount previously mounted disks
umount /mnt
umount /datadisks/disk1

# set up data disk
wipefs -a /dev/sdc1
make-bcache -B /dev/sdc1
echo 1 > /sys/block/sdc/sdc1/bcache/running
sleep 1
mkfs.ext4 /dev/bcache0
mount /dev/bcache0 /datadisks/disk1

# recreate elasticsearch directories
mkdir /datadisks/disk1/elasticsearch
chown elasticsearch:elasticsearch /datadisks/disk1/elasticsearch

# set up bcache init script
cat > /etc/init.d/bcache <<'EOT'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          bcache
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: bcache
# Description:       Enables bcache
### END INIT INFO#
# adjusted from http://blog.rralcala.com/2014/08/using-bcache-in-ec2.html
#
export basedisk=sdc/
export base=sdc1
export cache=sdb1

rc=0
start() {
  if [ ! -e /sys/block/bcache0/bcache/cache ]
  then
    echo 1 > /sys/block/$basedisk$base/bcache/running
    sleep 3
    umount /dev/$cache
    /sbin/wipefs -a -t ext2,ext3,ext4 /dev/$cache
    /usr/sbin/make-bcache -C /dev/$cache
    echo /dev/$cache > /sys/fs/bcache/register
    sleep 1
    name=`basename /sys/fs/bcache/*-*-*`
    echo $name > /sys/block/bcache0/bcache/attach
    # Some performance tuning, we assume NAS is always
    # going to be slower than local SSDs
    echo 0 > /sys/block/bcache0/bcache/sequential_cutoff
    sleep 1
    echo 0 > /sys/block/bcache0/bcache/cache/congested_read_threshold_us
    echo 0 > /sys/block/bcache0/bcache/cache/congested_write_threshold_us
  fi
  touch /var/lock/subsys/bcache
  return 0
}

stop() {
   echo 1 > /sys/block/bcache0/bcache/cache/unregister
   /bin/sleep 5
   rm -f /var/lock/subsys/bcache
   return 0
}

status() {
    cat /sys/block/bcache0/bcache/state
    return 0
}

case "$1" in
    start)
        start
        rc=$?
        ;;
    stop)
        stop
        rc=$
        ;;
    status)
        status
        rc=$?
        ;;
esac

exit $rc
EOT
chmod +x /etc/init.d/bcache
update-rc.d bcache defaults
/etc/init.d/bcache start

monit start elasticsearch