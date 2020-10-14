Setup
=====

```bash

# Make sure nfs kernel module is loaded
sudo modprobe nfs

# Start NFS Server 
./run_nfs_server.sh

# Find NFS Server address
docker inspect nfsserver | grep "IPAddress"

# Mount data directory example !!!
mkdir -p test

sudo mount -t nfs4 -o proto=tcp  172.18.0.2:/data $(pwd)/test
```

Cleanup
=======

```bash
sudo umount $(pwd)/test
docker stop nfsserver
```