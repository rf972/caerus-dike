#!/bin/bash
echo "master ip is: $SPARK_MASTER_HOST"
./sbin/start-master.sh --ip $SPARK_MASTER_HOST --port 7077 > /opt/volume/logs/master.log 2>&1 &
# --properties-file /conf/spark-defaults.conf
echo "SPARK_MASTER_READY"
echo "SPARK_MASTER_READY" > /opt/volume/status/SPARK_MASTER_STATE

echo "RUNNING_MODE $RUNNING_MODE"

if [ "$RUNNING_MODE" = "daemon" ]; then
    sleep infinity
fi
