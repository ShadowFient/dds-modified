FROM ubuntu
# copy source code to container
COPY . /app

# noninteractive only when build
ARG DEBIAN_FRONTEND=noninteractive

# Ali apt-get source.list
RUN sed -i s@/ports.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
	&& rm -Rf /var/lib/apt/lists/

# install dependencies
RUN apt update
RUN apt install openssh-server python3 python3-pip python-is-python3 ffmpeg -y
RUN python -m pip install flask munch networkx pyyaml requests \
	opencv-contrib-python

# allow ssh to the container as root and add local public key to the authorized keys
RUN echo "PermitRootLogin without-password" > /etc/ssh/sshd_config
RUN --mount=type=secret,id=my_secret mkdir -p -m 0600 /root/.ssh \
	&& echo $(cat /run/secrets/my_secret) > /root/.ssh/authorized_keyss

# listening on port 22
EXPOSE 22

CMD echo "export LD_LIBRARY_PATH=/opt/openblas/0.3.10/lib:" >> /home/ubuntu/.bashrc \
	&& sudo service ssh restart \
	&& bash