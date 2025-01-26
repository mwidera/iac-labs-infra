FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get clean

RUN echo 'root:example' | chpasswd 
RUN mkdir -p /run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
