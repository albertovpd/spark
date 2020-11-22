#!/bin/bash

TMP_DIR=/tmp/spark/kubernetes/v3
rm -rf $TMP_DIR && mkdir -p $TMP_DIR

wget https://archive.apache.org/dist/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz -P $TMP_DIR
tar -zxf $TMP_DIR/spark-3.0.1-bin-hadoop3.2.tgz -C $TMP_DIR
chmod 777 $TMP_DIR/spark-3.0.1-bin-hadoop3.2
chmod 777 $TMP_DIR/spark-3.0.1-bin-hadoop3.2/python
chmod 777 $TMP_DIR/spark-3.0.1-bin-hadoop3.2/python/pyspark

cd $TMP_DIR/spark-3.0.1-bin-hadoop3.2
./bin/docker-image-tool.sh -r $DOCKER_ACC -t v3.0.1 build
./bin/docker-image-tool.sh -r $DOCKER_ACC -t v3.0.1 -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
./bin/docker-image-tool.sh -r $DOCKER_ACC -t v3.0.1 push
