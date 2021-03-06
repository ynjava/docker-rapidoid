FROM openjdk:8-jre-slim
MAINTAINER Nikolche Mihajlovski

# GPG key of Rapidoid's author/maintainer (616EF49C: Nikolche Mihajlovski <nikolce.mihajlovski@gmail.com>)
ENV GPG_KEY E306FEF548C686C23DC00242B9B08D8F616EF49C

ENV RAPIDOID_JAR /opt/rapidoid.jar
ENV RAPIDOID_TMP /tmp/rapidoid

WORKDIR /opt
EXPOSE 8888

VOLUME /data

ENV RAPIDOID_VERSION 5.4.6
ENV RAPIDOID_URL https://repo1.maven.org/maven2/org/rapidoid/rapidoid-platform/$RAPIDOID_VERSION/rapidoid-platform-$RAPIDOID_VERSION.jar

COPY entrypoint.sh /opt/

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl dirmngr gnupg \
    && mkdir /platform \
    && mkdir -p "$RAPIDOID_TMP" \
	&& curl -SL "$RAPIDOID_URL" -o $RAPIDOID_JAR \
	&& curl -SL "$RAPIDOID_URL.asc" -o $RAPIDOID_JAR.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY \
	&& gpg --batch --verify $RAPIDOID_JAR.asc $RAPIDOID_JAR \
	&& rm -rf "$GNUPGHOME" \
	&& rm "$RAPIDOID_JAR.asc" \
	&& rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/opt/entrypoint.sh"]

