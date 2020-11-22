#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "Recreate pyspark2_env" \
    "Version" \
    "SparkPi example" \
    "PySpark, open Spyder" \
    "PySpark, start notebook" \
    "Uninstall" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            TMP_DIR=/tmp/spark/local/v2
            rm -rf $TMP_DIR && mkdir -p $TMP_DIR
            wget https://archive.apache.org/dist/spark/spark-2.4.6/spark-2.4.6-bin-hadoop2.7.tgz -P $TMP_DIR
            tar -zxf $TMP_DIR/spark-2.4.6-bin-hadoop2.7.tgz -C $HOME
            mv $HOME/spark-* $HOME/spark2
            chmod 777 $HOME/spark2
            chmod 777 $HOME/spark2/python
            chmod 777 $HOME/spark2/python/pyspark

            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            conda env create -f ./scripts/local/v2/environment.yml
            conda activate pyspark2_env && conda info --envs
            break
            ;;

        "Recreate pyspark2_env")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            conda remove -y -n pyspark2_env --all
            conda env create -f ./scripts/local/v2/environment.yml
            break
            ;;

        "Version")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark2_env && conda info --envs
            export SPARK_HOME=$HOME/spark2 && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            spark-submit --version && spark-submit ./scripts/resources/python_version.py
            break
            ;;

        "SparkPi example")
            export SPARK_HOME=$HOME/spark2 && export PATH=$SPARK_HOME/bin:$PATH
            spark-submit \
                --class org.apache.spark.examples.SparkPi \
                $SPARK_HOME/examples/jars/spark-examples_*.jar
            break
            ;;

        "PySpark, open Spyder")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark2_env && conda info --envs
            export SPARK_HOME=$HOME/spark2 && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            spyder 1> /dev/null 2>&1 &
            break
            ;;

        "PySpark, start notebook")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark2_env && conda info --envs
            export SPARK_HOME=$HOME/spark2 && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            export PYSPARK_DRIVER_PYTHON=jupyter
            export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
            cd $HOME
            pyspark
            break
            ;;

        "Uninstall")
            rm -rf $HOME/spark2
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            conda remove -y -n pyspark2_env --all
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
