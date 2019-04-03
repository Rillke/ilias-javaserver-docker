FROM openjdk:8-jre-alpine

ARG BUILD_NO

RUN apk add --no-cache \
	bash gettext curl

# Add ILIAS search index files (Java Server + XML descriptions)
# and configuration, startup scripts
COPY assets/ilias-lucene /var/www/ilias
COPY assets/lucene/ /lucene/

WORKDIR /var/www/ilias/Services/WebServices/RPC/lib

EXPOSE 11111

HEALTHCHECK --interval=5s --timeout=4s --start-period=20s CMD /lucene/docker-healthcheck.sh
ENTRYPOINT ["/lucene/lucene-entrypoint.sh"]
CMD ["java","-jar","./ilServer.jar","/lucene/index.ini","start"]

