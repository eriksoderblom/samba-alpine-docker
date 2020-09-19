FROM alpine:3.12
LABEL MAINTAINER="Peter Winter <peter@pwntr.com>" \
    Description="Simple and lightweight Samba docker container, based on Alpine Linux." \
    Version="4.12.6-r0"

# upgrade base system and install samba and supervisord
RUN apk --no-cache upgrade && apk --no-cache add samba samba-common-tools supervisor

# create a dir for the config and the share
RUN mkdir /config /shared

# copy config files from project folder to get a default config going for samba and supervisord
COPY *.conf /config/

# add a non-root user and group called "smb" with no password, no home dir, no shell, and gid/uid set to 1000
RUN addgroup -g 1000 smb && adduser -D -H -G smb -s /bin/false -u 1000 smb

# create a samba user matching our user from above with a very simple password ("letsdance")
RUN echo -e "letsdance\nletsdance" | smbpasswd -a -s -c /config/smb.conf smb

# volume mappings
VOLUME /config /shared

# exposes samba's default ports (135 for End Point Mapper [DCE/RPC Locator Service],
# 137, 138 for nmbd and 139, 445 for smbd)
EXPOSE 135/tcp 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["supervisord", "-c", "/config/supervisord.conf"]
