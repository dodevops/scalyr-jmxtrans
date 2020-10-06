FROM jmxtrans/jmxtrans

COPY scalyr-entrypoint.sh /
COPY jmxtrans.json.mustache /

RUN apk add python; \
    curl -sSL https://git.io/get-mo -o /usr/local/bin/mo; \
    chmod +x /usr/local/bin/mo; \
    chmod +x /scalyr-entrypoint.sh


ENTRYPOINT /scalyr-entrypoint.sh
