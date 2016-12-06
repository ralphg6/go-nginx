FROM nginx:1.10.1

# Instalação de serviços básicos linux (vi, curl)
RUN apt-get update &&  \
    apt-get install -y vim curl supervisor

# Instalação da linguagem Go versão 1.7

RUN apt-get update &&  \
    apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
    git \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

COPY go-wrapper /usr/local/bin/
RUN chmod +x /usr/local/bin/go-wrapper

# Fixando a versão do etcd na 3.0
#WORKDIR /go/src/github.com/coreos/etcd

#RUN git clone -b release-3.0 --depth 1 https://github.com/coreos/etcd.git .

#RUN git tag -l

RUN go get github.com/coreos/etcd
RUN go get github.com/docker/docker

RUN ONBUILD go-wrapper download
RUN ONBUILD go-wrapper install
