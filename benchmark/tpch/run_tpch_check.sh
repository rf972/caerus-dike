#! /bin/bash
set -e
CURRENT_TIME=$(date "+%Y-%m-%d-%H-%M-%S")
RESULTS_FILE="./${CURRENT_TIME}_result.csv"
echo "results file is: $RESULTS_FILE"

TESTS="-t 1-22,106,121"
#EXTRA_DEFAULT="--dry_run --results $RESULTS_FILE"
EXTRA_DEFAULT="--results $RESULTS_FILE"
init_test() {
  ./build_tbl.sh ../../data
  ./run_tpch.sh --mode initCsv
  ./run_tpch.sh --mode initParquet
}
hdfs_baseline() {
    local WORKERS="--workers $1"
    local EXTRA="$2 "
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds spark --protocol hdfs $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds spark --protocol webhdfs $EXTRA"
}
hdfs_all() {
    local WORKERS="--workers $1"
    local EXTRA="$2"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushFilter --pushProject $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol webhdfs $EXTRA"
}
hdfs_csv() {
    local WORKERS="--workers $1"
    local EXTRA="$2 --format csv"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushdown $EXTRA"
}
hdfs_csv_extra() {
    local WORKERS="--workers $1"
    local EXTRA="$2 --format csv"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --pushFilter --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol webhdfs $EXTRA"
}
hdfs_parquet_sanity() {
    local WORKERS="--workers $1"
    local EXTRA="$2 --format parquet"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushFilter --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushdown $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet --pushdown $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet --pushFilter --pushProject $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet $EXTRA"
}
hdfs_parquet() {
    local WORKERS="--workers $1"
    local EXTRA="$2 --format parquet"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushProject --pushFilter $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushdown $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat binary --pushdown $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet --pushFilter --pushProject $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet $EXTRA"
    #./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet $EXTRA"
}
hdfs_parquet_extra() {
    local WORKERS="--workers $1"
    local EXTRA="$2 --format parquet"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol hdfs --outputFormat parquet --pushProject $EXTRA"

    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol ndphdfs --outputFormat parquet --pushProject --pushFilter $EXTRA"
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

    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushdown $EXTRA"
}
s3_file_extra() {
    local WORKERS="--workers $1"
    shift
    local EXTRA="$*"

    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds spark --protocol file $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushProject $EXTRA"
    ./run_tpch.py $WORKERS $TESTS $EXTRA_DEFAULT -a "-ds ndp --protocol s3 --pushFilter --pushProject $EXTRA"
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
elif [ "$1" == "hdfsparquetcheck" ]; then
  hdfs_all 1 "--format parquet --outputFormat csv --check"
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
elif [ "$1" == "allhdfs" ]; then
  hdfs_parquet_extra 1 "--check"
  hdfs_csv_extra 1 "--check"
elif [ "$1" == "hdfsparquetsanity" ]; then
  hdfs_parquet_sanity 1 "--check"
elif [ "$1" == "hdfsparquet" ]; then
  hdfs_baseline 1 "--format parquet --check"
  hdfs_parquet 1 "--check"
  hdfs_parquet_extra 1 "--check"
elif [ "$1" == "hdfsparquetperf" ]; then
  hdfs_baseline 4 "--format parquet"
  hdfs_parquet 4 ""
elif [ "$1" == "hdfsextra" ]; then
  hdfs_csv_extra 1 "--check"
  hdfs_parquet_extra 1 "--check"
elif [ "$1" == "hdfscsv" ]; then
  hdfs_baseline 1 "--format csv --check"
  hdfs_csv 1 "--check"
elif [ "$1" == "alls3" ]; then
  s3_file_extra 1 "--check"
elif [ "$1" == "all" ]; then
  hdfs_baseline 1 "--format parquet --check"
  hdfs_parquet 1 "--check"
  hdfs_baseline 1 "--format csv --check"
  hdfs_csv 1 "--check"
  hdfs_csv_extra 1 "--check"
  hdfs_parquet_extra 1 "--check"
  #s3_file_all 1 "--check"
else
  echo "missing test: provide test to run (hdfscheck,hdfsperf,hdfsshort,s3check,s3perf)"
fi
#./diff_tpch.py --terse
