FROM	alpine:latest	AS	resource

RUN	apk add --no-cache \
	--update \
	openssl \
	libcurl \
	libxml2 \
	libssh-dev \
	libressl-dev \
	libxml2-dev \
	curl-dev \
	pinentry \
	xclip \
	git \
	make \
	cmake \
	g++ \
	bash \
	bash-completion \
	coreutils
RUN	git clone https://github.com/lastpass/lastpass-cli
WORKDIR	/lastpass-cli
RUN	make install
WORKDIR	/
RUN	rm -rf lastpass-cli \
	&& apk del curl-dev xclip cmake

# latest released jq version 1.6 does not contain https://github.com/stedolan/jq/pull/1752 => build from master
RUN	apk add --no-cache \
	--update \
	flex \
	bison \
	libtool \
	automake \
	autoconf
RUN	git clone https://github.com/stedolan/jq.git
WORKDIR	/jq
RUN	git submodule update --init \
	&& autoreconf -fi \
	&& ./configure --with-oniguruma=builtin \
	&& make -j8 \
	&& make check \
	&& make LDFLAGS=-all-static \
	&& make install
WORKDIR	/
RUN	rm -rf jq \
	&& apk del flex bison libtool make automake autoconf g++

FROM	resource	AS	tests

RUN apk add coreutils ncurses curl
RUN curl -#L https://github.com/bats-core/bats-core/archive/master.zip | unzip - \
  && bash bats-core-master/install.sh /usr/local \
  && rm -rf ./bats-core-master
ENV TERM xterm-256color

COPY	.	/lastpass-resource
WORKDIR	/lastpass-resource/test
RUN	bats .

FROM	resource

COPY assets/*	/opt/resource/
RUN	chmod +x /opt/resource/*
