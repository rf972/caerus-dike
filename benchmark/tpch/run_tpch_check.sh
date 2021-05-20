#! /bin/bash
set -e
CURRENT_TIME=$(date "+%Y-%m-%d-%H-%M-%S")
RESULTS_FILE="./${CURRENT_TIME}_result.csv"
echo "results file is: $RESULTS_FILE"

TESTS="-t 1-22"
#EXTRA_DEFAULT="--dry_run --results $RESULTS_FILE"
EXTRA_DEFAULT="--results $RESULTS_FILE"
hdfs_baseline() {
    local WORKERS="--workers $1"
    local EXTRA="$2"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds spark --protocol hdfs $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds spark --protocol webhdfs $EXTRA"
}
hdfs_all() {
    local WORKERS="--workers $1"
    local EXTRA="$2"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushProject $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushFilter --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushdown $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol webhdfs $EXTRA"
}
hdfs_check() {
    local EXTRA=$1
    hdfs_all 1 "$EXTRA"
    hdfs_all 4 "$EXTRA"
}
hdfs_perf() {
    local EXTRA=$1
    hdfs_baseline 1 "$EXTRA"
    hdfs_all 1 "$EXTRA"
    hdfs_baseline 4 "$EXTRA"
    hdfs_all 4 "$EXTRA"
}
hdfs_short() {
    local EXTRA=$1
    hdfs_baseline 4 "$EXTRA"
    hdfs_all 4 "$EXTRA"
}
s3_filePart() {
    local WORKERS="--workers $1"
    shift
    local EXTRA="$*"

    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --filePart $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --filePart --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --filePart --pushFilter --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --filePart --pushdown $EXTRA"
}
s3_file() {
    local WORKERS="--workers $1"
    shift
    local EXTRA="$*"

    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "--ds spark --protocol file $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushProject $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushFilter --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushdown $EXTRA"
}
s3() {
    local EXTRA="$*"
    echo $EXTRA
    #s3_filePart 1 $EXTRA
    #s3_filePart 4 $EXTRA
    s3_file 1 $EXTRA
}
s3_short() {
    local EXTRA=$*
    s3_file 4 "$EXTRA"
}
if [ "$1" == "hdfscheck" ]; then
  hdfs_check "--check"
elif [ "$1" == "hdfsshort" ]; then
  hdfs_short "--format csv"
elif [ "$1" == "hdfsperf" ]; then
  hdfs_perf ""
elif [ "$1" == "s3miniocheck" ]; then
  s3 "--options minio --format csv --check"
elif [ "$1" == "s3minio" ]; then
  s3_short "--options minio --format csv"
elif [ "$1" == "s3check" ]; then
  s3 "--check"
elif [ "$1" == "s3perf" ]; then
  s3 ""
elif [ "$1" == "s3short" ]; then
  s3_short "--format csv"
elif [ "$1" == "all" ]; then
  hdfs ""
  hdfs "--check"
  s3 ""
  s3 "--check"
else
  echo "missing test: provide test to run (hdfscheck,hdfsperf,hdfsshort,s3check,s3perf)"
fi
#./diff_tpch.py --terse 
