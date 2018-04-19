FROM debian:sid

LABEL maintainer="github@lplab.net" \
      version="5.8.12" \
      description="Unifi Controller Docker container"

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install wget procps manpages gnupg openjdk-8-jre-headless && \
    apt-get clean

ENV CTRL_URL https://dl.ubnt.com/unifi/5.8.12-e2c271f29d/unifi_sysvinit_all.deb
RUN wget -nv -O /unifi_sysvinit_all.deb ${CTRL_URL} && \
    dpkg -i --force-all /unifi_sysvinit_all.deb && \
    apt-get -f -y install && \
    rm -f /unifi_sysvinit_all.deb && \
    apt-get clean

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --verify /tini.asc
RUN chmod +x /tini

ADD unifi /etc/init.d/unifi
RUN chmod +x /etc/init.d/unifi

ADD entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

ENV BASEDIR=/usr/lib/unifi \
  DATADIR=/var/lib/unifi \
  RUNDIR=/var/run/unifi \
  LOGDIR=/var/log/unifi \
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
  JVM_MAX_HEAP_SIZE=1024M \
  JVM_INIT_HEAP_SIZE=

RUN ln -s ${BASEDIR}/data ${DATADIR} && \
  ln -s ${BASEDIR}/run ${RUNDIR} && \
  ln -s ${BASEDIR}/logs ${LOGDIR} && \
  ln -s /usr/bin/mongod /usr/lib/unifi/bin/

VOLUME ["${DATADIR}", "${RUNDIR}", "${LOGDIR}"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp 3478/tcp
ENTRYPOINT ["/tini", "--"]

CMD ["/sbin/entrypoint.sh"]
