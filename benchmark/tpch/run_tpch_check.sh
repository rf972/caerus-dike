#! /bin/bash
set -e
CURRENT_TIME=$(date "+%Y-%m-%d-%H-%M-%S")
RESULTS_FILE="./${CURRENT_TIME}_result.csv"
echo "results file is: $RESULTS_FILE"

TESTS="-t 1-22"
#EXTRA_DEFAULT="--dry_run --results $RESULTS_FILE"
EXTRA_DEFAULT="--results $RESULTS_FILE"

hdfs_all() {
    local WORKERS="--workers $1"
    local EXTRA="$2"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblHdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblWebHdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblHdfsDs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblWebHdfsDs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblDikeHdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblDikeHdfsNoProc $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblDikeHdfs --s3Filter --s3Project $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblDikeHdfs --s3Select $EXTRA"
}
hdfs() {
    local EXTRA=$1
    hdfs_all 1 "-p 1 $EXTRA"
    hdfs_all 1 "$EXTRA"
    hdfs_all 4 "$EXTRA"
    hdfs_all 6 "$EXTRA"
}
s3_tblPart() {
    local WORKERS="--workers $1"
    local EXTRA="$2"

    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblPartS3 $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblPartS3 --s3Filter --s3Project $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblPartS3 --s3Select $EXTRA"
}
s3_tbl() {
    local WORKERS="--workers $1"
    local EXTRA=$2

    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "--test tblFile $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblS3 $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblS3 --s3Filter --s3Project $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "$WORKERS --test tblS3 --s3Select $EXTRA"
}
s3() {
    local EXTRA=$1

    s3_tblPart 1 $EXTRA
    s3_tblPart 4 $EXTRA
    s3_tblPart 6 $EXTRA
    s3_tbl 1 "-p 1 $EXTRA"
}
if [ "$1" == "hdfscheck" ]; then
  hdfs "--check"
elif [ "$1" == "hdfsperf" ]; then
  hdfs ""
elif [ "$1" == "s3check" ]; then
  s3 "--check"
elif [ "$1" == "s3perf" ]; then
  s3 ""
elif [ "$1" == "all" ]; then
  hdfs ""
  hdfs "--check"
  s3 ""
  s3 "--check"
else
  echo "missing test: provide test to run (hdfscheck,hdfsperf,s3check,s3perf)"
fi
#./diff_tpch.py --terse 
