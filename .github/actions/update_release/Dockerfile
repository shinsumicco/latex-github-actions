FROM python:3.7.6-alpine3.10

RUN apk add curl

ADD entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
