To build/run interactively:


cd spark/docker
build_dockers.sh

cd ..
examples/ndp/build.sh debug
sbt
package
run /tpch-test/lineitem.tbl
