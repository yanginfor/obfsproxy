# sshd
#
# VERSION               0.0.2

FROM ubuntu:14.04
MAINTAINER Sven Dowideit <SvenDowideit@docker.com>

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
# install shadowsocks
RUN apt-get install -y python-setuptools && easy_install pip
RUN apt-get install -y m2crypto
RUN apt-get install -y python-dev
RUN pip install shadowsocks
# install obfsproxy
RUN apt-get install -y gcc
RUN pip install obfsproxy
RUN nohup obfsproxy --data-dir=/tmp/scramblesuit-server scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS554 --dest=127.0.0.1:8001 server 0.0.0.0:8001 &
RUN nohup ssserver -p 8001 -k OTdlZDEyMW -m aes-256-cfb –-user nobody --log-file access.log -d start &

EXPOSE 22
EXPOSE 8001-8010
CMD ["/usr/sbin/sshd", "-D"]
