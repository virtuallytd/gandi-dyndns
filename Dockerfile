FROM alpine:3.15

RUN apk add --no-cache curl jq

COPY update_dns.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/update_dns.sh

COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["crond", "-f"]
