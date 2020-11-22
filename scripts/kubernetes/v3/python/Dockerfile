FROM borjagilperez/spark-py:v3.0.1

COPY ./scripts/local/v3/requirements.txt /opt/spark/work-dir/

USER 0

RUN pip3 install -r /opt/spark/work-dir/requirements.txt && \
    rm /opt/spark/work-dir/requirements.txt

USER ${spark_uid}

COPY ./examples/src/main/python/v3-0-1/kubernetes/* /opt/spark/work-dir/examples/
