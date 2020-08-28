```bash
git clone https://github.com/peterpuhov-github/dike.git
git submodule update --recursive
cd dike/minio/docker
./build_dockers.sh
../
./build_server.sh
./run_server.sh
```
