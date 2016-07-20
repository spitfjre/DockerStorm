#
## DockerStorm
#
# eventstorm/dockerstorm
#
# BUILD: docker build -t eventstorm/dockerstorm -f ./Dockerfile .
#
# RUN (service) : docker run -p 8080:8080 -t -i eventstorm/dockerstorm
#
FROM ubuntu:15.10

RUN apt-get update
RUN apt-get upgrade -y

# Install Oracle JDK 8 and others useful packages
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get clean autoclean
RUN apt-get autoremove -y

ENV STORM_VERSION 1.0.1
ENV ZOOKEEPER_VERSION 3.4.8

# Create storm group and user
ENV STORM_HOME /usr/share/apache-storm
RUN groupadd storm; useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm

# Download and Install Apache Storm
RUN wget http://mirror.softaculous.com/apache/storm/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz
RUN tar -xzvf apache-storm-$STORM_VERSION.tar.gz -C /usr/share
RUN rm -rf apache-storm-$STORM_VERSION.tar.gz
ADD storm.yaml /usr/share/apache-storm-$STORM_VERSION/conf/

# Download and Install Apache Zookeeper
RUN wget http://mirror.synyx.de/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz
RUN tar -xzvf zookeeper-$ZOOKEEPER_VERSION.tar.gz -C /usr/share
RUN rm -rf zookeeper-$ZOOKEEPER_VERSION.tar.gz
ADD zoo.cfg /usr/share/zookeeper-$ZOOKEEPER_VERSION/conf/
RUN mkdir -p /usr/share/storm/datadir/zookeeper

# Download and Install Supervisor
RUN apt-get install supervisor -y
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

# Copy project
WORKDIR /DockerStorm
ADD . /DockerStorm/

CMD ["/DockerStorm/entrypoint.sh"]