#!/bin/bash

PS3="Please select your choice: "
options=(
    "spark{-py}:v3.0.1 Docker base images, build and push" \
    "spark-py:v3.0.1-plus-{branch} Docker image, build and push" \
    "SparkPi example" \
    "PySpark, PandasUDF example" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "spark{-py}:v3.0.1 Docker base images, build and push")
            read -p 'Docker account [borjagilperez]: ' DOCKER_ACC
            if [ -z "$DOCKER_ACC" ]; then
                export DOCKER_ACC='borjagilperez'
            fi
            bash ./scripts/kubernetes/v3/base.sh
            break
            ;;

        "spark-py:v3.0.1-plus-{branch} Docker image, build and push")
            read -p 'Docker account [borjagilperez]: ' DOCKER_ACC
            if [ -z "$DOCKER_ACC" ]; then
                export DOCKER_ACC='borjagilperez'
            fi
            bash ./scripts/kubernetes/v3/python/plus.sh
            break
            ;;

        "SparkPi example")
            K8S_MASTER=$(kubectl cluster-info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | awk -F' ' 'NR==1{print $6}')
            read -p 'Docker image [borjagilperez/spark-py:v3.0.1-plus-latest]: ' IMAGE
            if [ -z "$IMAGE" ]; then
                IMAGE='borjagilperez/spark-py:v3.0.1-plus-latest'
            fi
            
            export SPARK_HOME=$HOME/spark3 && export PATH=$SPARK_HOME/bin:$PATH
            spark-submit \
                --name spark-pi \
                --master k8s://$K8S_MASTER \
                --deploy-mode cluster \
                --conf spark.kubernetes.namespace=spark \
                --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
                --conf spark.kubernetes.container.image=$IMAGE \
                --conf spark.kubernetes.container.image.pullPolicy=Always \
                --conf spark.kubernetes.pyspark.pythonVersion=3 \
                --conf spark.driver.cores=1 \
                --conf spark.driver.memory=1g \
                --conf spark.executor.instances=2 \
                --conf spark.executor.cores=1 \
                --conf spark.executor.memory=1g \
                --class org.apache.spark.examples.SparkPi \
                local:///opt/spark/examples/jars/spark-examples_2.12-3.0.1.jar 10000
            break
            ;;

        "PySpark, PandasUDF example")
            K8S_MASTER=$(kubectl cluster-info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | awk -F' ' 'NR==1{print $6; exit}')
            read -p 'Docker image [borjagilperez/spark-py:v3.0.1-plus-latest]: ' IMAGE
            if [ -z "$IMAGE" ]; then
                IMAGE='borjagilperez/spark-py:v3.0.1-plus-latest'
            fi
            LAUNCHER=/opt/spark/work-dir/examples/pandasudf.py

            export SPARK_HOME=$HOME/spark3 && export PATH=$SPARK_HOME/bin:$PATH
            spark-submit \
                --name pandasudf-example \
                --master k8s://$K8S_MASTER \
                --deploy-mode cluster \
                --conf spark.kubernetes.namespace=spark \
                --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
                --conf spark.kubernetes.container.image=$IMAGE \
                --conf spark.kubernetes.container.image.pullPolicy=Always \
                --conf spark.kubernetes.pyspark.pythonVersion=3 \
                --conf spark.driver.cores=1 \
                --conf spark.driver.memory=1g \
                --conf spark.executor.instances=2 \
                --conf spark.executor.cores=1 \
                --conf spark.executor.memory=1g \
                local://$LAUNCHER
            break
            ;;

        "Quit")
            break
            ;;
        *)
            echo "Invalid option"
            break
            ;;
    esac
done
