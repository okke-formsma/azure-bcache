~# azure-bcache
Scripts to install bcache in azure.

Use the ephemeral (temporary) azure disk as a bcache cache for /dev/sdc1.

This script assumes an installation of the elasticsearch azure-marketplace VMs.

This is a work in progress. The best place to put all these functions would be in the elastic/azure-marketplace/ repo or a copy of that, but this is a work in progress.

It seems the bcache extension is not correctly configured in ubuntu. This  bug forces us to run this script in 2 parts:

    wget https://raw.githubusercontent.com/okke-formsma/azure-bcache/master/bcache-install.sh
    chmod +x bcache-install.sh
    ./bcache-install.sh
    
    wget https://raw.githubusercontent.com/okke-formsma/azure-bcache/master/nodeexporter-install.sh
    chmod +x nodeexporter-install.sh
    ./nodeexporter-install.sh