FROM jenkins

# We need root to install packages
USER root

RUN yum install -y docker wget

RUN cd /usr/local/bin && \
    wget https://github.com/openshift/origin/releases/download/v1.3.2/openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    tar -zxvf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    cp openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit/oc /usr/local/bin/ && \
    rm -f openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    rm -rf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit && \
    chmod 777 /usr/local/bin/oc
    
COPY /docker.repo /etc/yum.repos.d/

# Install docker-engine
RUN ls -la /etc/yum.repos.d && \
    yum clean all -y && \
    INSTALL_PKGS="docker-engine-1.8.2" && \
    yum update -y && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME
    
# install SKOPEO
ENV SKOPEO_BIN=https://github.com/sabre1041/ocp-support-resources/blob/master/skopeo/bin/skopeo?raw=true

COPY /policy.json /etc/containers/

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME && \
    curl -L -o /usr/bin/skopeo $SKOPEO_BIN && \
    chown -R 1001:0 /etc/containers && \
    chmod -R g+rw /etc/containers

# drop back to the jenkins user 
USER jenkins
