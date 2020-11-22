#!/bin/bash

TMP_DIR=/tmp/spark/kubernetes/v2
rm -rf $TMP_DIR && mkdir -p $TMP_DIR

wget https://archive.apache.org/dist/spark/spark-2.4.6/spark-2.4.6-bin-hadoop2.7.tgz -P $TMP_DIR
tar -zxf $TMP_DIR/spark-2.4.6-bin-hadoop2.7.tgz -C $TMP_DIR
chmod 777 $TMP_DIR/spark-2.4.6-bin-hadoop2.7
chmod 777 $TMP_DIR/spark-2.4.6-bin-hadoop2.7/python
chmod 777 $TMP_DIR/spark-2.4.6-bin-hadoop2.7/python/pyspark

cd $TMP_DIR/spark-2.4.6-bin-hadoop2.7
./bin/docker-image-tool.sh -r $DOCKER_ACC -t v2.4.6 build
./bin/docker-image-tool.sh -r $DOCKER_ACC -t v2.4.6 push
