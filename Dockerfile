FROM jenkins
# if we want to install via apt
USER root

#RUN apt-get update && apt-get install -y ruby docker wget
RUN apk add -y wget
RUN apk add -y docker


RUN cd /usr/local/bin && \
    wget https://github.com/openshift/origin/releases/download/v1.3.2/openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    tar -zxvf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    cp openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit/oc /usr/local/bin/ && \
    rm -f openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz && \
    rm -rf openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit && \
    chmod 777 /usr/local/bin/oc
    

USER jenkins 
# drop back to the regular jenkins user - good practice
