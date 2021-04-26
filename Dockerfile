ARG PJSUA_VER=2.11
ARG TS3_VER=3.5.6
FROM spritsail/debian-builder:buster-slim as builder

ARG MAKEFLAGS
ARG PJSUA_VER
ARG TS3_VER

# Set up output structure, install needed headers
RUN mkdir -p /output/usr/bin/ /output/opt/ \
 && apt-get install -y --no-install-recommends libasound2-dev

# Build pjsua & copy the binary we need
WORKDIR /tmp/pjsua

RUN curl -sSL https://github.com/pjsip/pjproject/archive/refs/tags/$PJSUA_VER.tar.gz | tar xz --strip-components=1 \
 && ./configure \
 && make dep && make \
 && cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /output/usr/bin/pjsua

# Download & Extract the Teamspeak Client
WORKDIR /tmp/teamspeak

RUN curl -sSL -o /tmp/teamspeak.run https://files.teamspeak-services.com/releases/client/$TS3_VER/TeamSpeak3-Client-linux_amd64-$TS3_VER.run \
 && chmod +x /tmp/teamspeak.run \
 && /tmp/teamspeak.run --nochown --tar xf \
 && cp -r /tmp/teamspeak /output/opt/teamspeak

# Strip all unneeded symbols for optimum size
RUN find /output -exec sh -c 'file "{}" | grep -q ELF && strip --strip-debug "{}"' \;

#=========================

FROM debian:bullseye-slim

ARG PJSUA_VER
ARG TS3_VER

LABEL maintainer="Adam Dodman <hello@dodman.co.uk>" \
      org.label-schema.vendor="Adam-Ant" \
      org.label-schema.name="DialABot" \
      org.label-schema.url="https://github.com/Adam-Ant/DialABot" \
      org.label-schema.description="A VOIP to Teamspeak3 bot bridge" \
      org.label-schema.version="1.0" \
      io.spritsail.version.pjsua=${PJSUA_VER} \
      io.spritsail.version.teamspeak=${TS3_VER}


RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends pulseaudio libasound2 xvfb x11vnc xauth dbus tini \
        # Teamspeak required libraries
        libnss3 libxcomposite1 libxcursor1 libpci3 libxslt1.1 libegl1 libxkbcommon0 \
 && apt-get clean

COPY --from=builder /output/ /
COPY root/ /

RUN chmod +x /usr/bin/*

ENV DISPLAY=":99"

VOLUME ["/config"]

ENTRYPOINT ["tini", "--"]

CMD ["/usr/bin/entrypoint"]
