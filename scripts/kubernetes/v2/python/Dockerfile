FROM borjagilperez/spark-py:v2.4.6

COPY ./scripts/local/v2/requirements.txt /opt/spark/work-dir/
RUN pip3 install -r /opt/spark/work-dir/requirements.txt && \
    rm /opt/spark/work-dir/requirements.txt

COPY ./examples/src/main/python/v2-4-6/kubernetes/* /opt/spark/work-dir/examples/
