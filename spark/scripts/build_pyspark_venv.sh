#!/bin/bash
# requires
#sudo apt-get update
#sudo apt-get install -y python3.8-venv
#sudo python3 -mpip install wheel

export PYNDP_PATH="/pyNdp"
pushd $PYNDP_PATH
python3 setup.py bdist_wheel
python3 setup.py sdist
echo "Finished building pyNdp"
popd

rm pyspark_venv.tar.gz
python3 -m venv pyspark_venv
source pyspark_venv/bin/activate
echo "Activated"
pip install wheel
pip install pyarrow pandas venv-pack fastparquet py4j duckdb pyspark sqlparse
echo "first install done"
pip install "$PYNDP_PATH/dist/pyNdp-0.1.tar.gz"
echo "install of pyNdp done"
venv-pack -o pyspark_venv.tar.gz
deactivate
