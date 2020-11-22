#!/bin/bash

PS3="Please select your choice: "
options=(
    "Create namespace, etc." \
    "Get secret token of Spark namespace" \
    "Info" \
    "Logs" \
    "Logs of last pod" \
    "Delete pods" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Create namespace, etc.")
            kubectl apply -f ./scripts/kubernetes/spark-rbac.yaml
            break
            ;;

        "Get secret token of Spark namespace")
            SPARK_SECRET_NAME=$(kubectl get -n spark secret | grep 'spark-token-' | awk -F' ' 'NR==1{print $1; exit}')
            SPARK_SECRET_TOKEN=$(kubectl describe -n spark secret $SPARK_SECRET_NAME | grep 'token:' | awk -F' ' 'END{print $2; exit}')
            echo $SPARK_SECRET_TOKEN
            break
            ;;

        "Info")
            kubectl get -n spark all
            break
            ;;

        "Logs")
            read -p 'Name: ' NAME
            kubectl logs -n spark $NAME
            break
            ;;

        "Logs of last pod")
            kubectl logs -n spark $(kubectl get -n spark pods --sort-by=.metadata.creationTimestamp | awk -F' ' 'END{print $1; exit}')
            break
            ;;

        "Delete pods")
            kubectl delete -n spark pods --all
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
