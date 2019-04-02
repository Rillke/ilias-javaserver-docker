FROM openjdk:8-jre-alpine

ARG TZ
ARG BUILD_NO

RUN apk add --no-cache \
	bash gettext

# ILIAS und Erweiterungen hinzufügen
# und Konfiguration hinzufügen
COPY assets/ilias-lucene /var/www/ilias
COPY assets/lucene/ /lucene/

# Einstiegspunkt setzen
ENTRYPOINT ["/lucene/lucene-entrypoint.sh"]
CMD ["java","-jar","./ilServer.jar","/lucene/index.ini","start"]
WORKDIR /var/www/ilias/Services/WebServices/RPC/lib

