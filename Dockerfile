#
## DockerStorm
#
# eventstorm/dockerstorm
#
# BUILD: docker build -t eventstorm/dockerstorm -f ./Dockerfile .

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
RUN apt-get install vim -y

ENV STORM_VERSION 1.0.2
ENV ZOOKEEPER_VERSION 3.4.8

# Download and Install Apache Storm
RUN wget http://mirror.softaculous.com/apache/storm/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz
RUN tar -xzvf apache-storm-$STORM_VERSION.tar.gz -C /usr/share
RUN mv /usr/share/apache-storm-$STORM_VERSION /usr/share/apache-storm
RUN rm -rf apache-storm-$STORM_VERSION.tar.gz
ADD storm.yaml /usr/share/apache-storm/conf/

# Download and Install Apache Zookeeper
RUN wget http://mirror.synyx.de/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz
RUN tar -xzvf zookeeper-$ZOOKEEPER_VERSION.tar.gz -C /usr/share
RUN mv /usr/share/zookeeper-$ZOOKEEPER_VERSION /usr/share/zookeeper
RUN rm -rf zookeeper-$ZOOKEEPER_VERSION.tar.gz
ADD zoo.cfg /usr/share/zookeeper/conf/
RUN mkdir -p /usr/share/storm/datadir/zookeeper

# Download and Install Supervisor
RUN apt-get install supervisor -y
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create storm group and user
ENV STORM_HOME "/usr/share/apache-storm/bin"
ENV PATH=$PATH:$STORM_HOME
RUN groupadd storm; useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm

# Copy project
WORKDIR /DockerStorm
ADD . /DockerStorm/

CMD ["/DockerStorm/entrypoint.sh"]