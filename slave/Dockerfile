
FROM openshift/jenkins-slave-base-centos7

MAINTAINER Raffaele Spazzoli <rspazzol@redhat.com>

# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-slave-docker-centos-docker" \
      name="openshift3/jenkins-slave-docker-rhel7" \
      version="3.3" \
      architecture="x86_64" \
      release="4" \
      io.k8s.display-name="Jenkins Slave Docker" \
      io.k8s.description="The jenkins slave docker image has the docker tools on top of the jenkins slave base image." \
      io.openshift.tags="openshift,jenkins,slave,docker"

USER root

COPY /docker.repo /etc/yum.repos.d/

#    yum-config-manager --disable "*" && \
#    yum-config-manager --enable dockerrepo rhel-7-server-rpms rhel-7-server-optional-rpms rhel-7-server-extras-rpms rhel-7-server-ose-3.3-rpms && \


# Install docker-engine
RUN ls -la /etc/yum.repos.d && \
    yum clean all -y && \
    INSTALL_PKGS="docker-engine" && \
    yum update -y && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001