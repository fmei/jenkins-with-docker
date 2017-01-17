FROM jenkins
# if we want to install via apt
USER root

#RUN apt-get update && apt-get install -y ruby docker wget
RUN yum install -y docker wget

RUN cd /usr/local/bin && \
    wget https://github.com/openshift/origin/releases/download/v1.3.2/openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    tar -zxvf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    cp openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit/oc /usr/local/bin/ && \
    rm -f openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    rm -rf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit && \
    chmod 777 /usr/local/bin/oc
    
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

USER jenkins 
# drop back to the regular jenkins user - good practice
