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
RUN echo '/usr/bin/nohup /usr/local/bin/obfsproxy --data-dir=/tmp/scramblesuit-server scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS554 --dest=127.0.0.1:8001 server 0.0.0.0:80  1>/root/nohup.out 2>&1 &' > /root/obfs.sh
RUN echo '/usr/bin/nohup /usr/local/bin/ssserver -p 8001 -k OTdlZDEyMW -m aes-256-cfb  --user nobody --log-file /root/access.log -d start 1>/root/nohup.out 2>&1 &' > /root/ss.sh
RUN echo '#!/bin/sh -e' >  /etc/rc.local
RUN echo 'sh /root/obfs.sh' >>  /etc/rc.local
RUN echo 'sh /root/ss.sh' >> /etc/rc.local
RUN chown root /etc/rc.local
RUN chmod 755 /etc/rc.local
RUN /etc/init.d/rc.local start

EXPOSE 80
EXPOSE 22
EXPOSE 8001-8010
#CMD ["/usr/sbin/sshd", "-D"]
CMD /etc/init.d/rc.local start && /usr/sbin/sshd -D  
