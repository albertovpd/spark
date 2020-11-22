#!/bin/bash

BRANCH=$(git branch | grep '*' | awk -F' ' 'NR==1{print $2}')
case $BRANCH in
    'master')
        LATEST_NAME="$DOCKER_ACC/spark-py:v3.0.1-plus-latest"
        CURR_VERSION=$(cat ./VERSION | awk -F' ' 'NR==1{print $1}')
        COMPLETE_NAME="$DOCKER_ACC/spark-py:v3.0.1-plus-$CURR_VERSION"
        BUILDS="-t $LATEST_NAME -t $COMPLETE_NAME"
        ;;
    *)
        BRANCH_NAME=$(git branch | grep '*' | awk -F' ' 'NR==1{print $2}' | sed -E "s/\//./g" | sed -E "s/-/./g")
        COMPLETE_NAME="$DOCKER_ACC/spark-py:v3.0.1-plus-$BRANCH_NAME"
        BUILDS="-t $COMPLETE_NAME"
        ;;
esac

docker build $BUILDS -f ./scripts/kubernetes/v3/python/Dockerfile .
docker push $COMPLETE_NAME
if [ "$BRANCH" == "master" ]; then
    docker push $LATEST_NAME
fi
