FROM ubuntu:bionic

RUN apt update 
RUN apt -y upgrade
RUN apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev software-properties-common git
RUN add-apt-repository ppa:bitcoin/bitcoin && apt update
RUN apt install -y libdb4.8-dev libdb4.8++-dev

RUN git clone https://github.com/keystore-com/bitcoin.git
RUN cd bitcoin && ./autogen.sh && ./configure --disable-tests --without-gui && make -j8 && make install
RUN rm -rvf bitcoin
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG USER_ID
ARG GROUP_ID

ENV HOME /bitcoin

ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

RUN groupadd -g ${GROUP_ID} bitcoin \
&& useradd -u ${USER_ID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

USER bitcoin

WORKDIR /bitcoin
VOLUME ["/bitcoin"]

ENTRYPOINT [ "/usr/local/bin/bitcoind" ]