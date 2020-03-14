FROM ubuntu:19.10

VOLUME /ssh-host-keys

# Install SSH server, but delete the keys and instead use a volume mounted later
# on. This way I'm not pushing server keys into dockerhub.
RUN apt-get update \
 && apt-get install -y openssh-server \
 && rm -f /etc/ssh/ssh_host_*_key \
 && ln -s /ssh-host-keys/ssh_host_rsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_dsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_ed25519_key /etc/ssh/ \
 && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
 && mkdir /var/run/sshd \
 && yes | /usr/local/sbin/unminimize

EXPOSE 22

ADD generate-host-keys /usr/sbin/

WORKDIR /
CMD /usr/sbin/generate-host-keys && exec /usr/sbin/sshd -D
