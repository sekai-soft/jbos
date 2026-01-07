FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.28

RUN bin/elasticsearch-plugin install --batch https://get.infini.cloud/elasticsearch/analysis-ik/7.17.28 && \
    bin/elasticsearch-plugin install --batch https://get.infini.cloud/elasticsearch/analysis-stconvert/7.17.28
