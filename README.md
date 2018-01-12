# azure-bcache
Scripts to install bcache in azure.

Use the ephemeral (temporary) azure disk as a bcache cache for /dev/sdc1.

This script assumes an installation of the elasticsearch azure-marketplace VMs.

This is a work in progress. The best place to put all these functions would be in the elastic/azure-marketplace/ repo or a copy of that, but this is a work in progress.

Run by wgetting the file and executing as root.