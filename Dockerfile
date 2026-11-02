FROM debian:testing
ARG optical_gid
ARG uid=1000

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    cd-paranoia \
    cdrdao \
    eject \
    flac \
    git \
    libcdio-dev \
    libcdio-paranoia-dev \
    libdiscid-dev \
    libiso9660-dev \
    libsndfile1-dev \
    locales \
    make \
    pkgconf \
    python3-cdio \
    python3-dev \
    python3-discid \
    python3-musicbrainzngs \
    python3-mutagen \
    python3-packaging \
    python3-pil \
    python3-pip \
    python3-ruamel.yaml \
    python3-setuptools \
    sox \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# add user (+ group workaround for ArchLinux)
RUN useradd -m worker --uid ${uid} -G cdrom \
    && if [ -n "${optical_gid}" ]; then groupadd -f -g "${optical_gid}" optical \
    && usermod -a -G "${optical_gid}" worker; fi \
    && mkdir -p /output /home/worker/.config/whipper \
    && chown worker: /output /home/worker/.config/whipper
VOLUME ["/home/worker/.config/whipper", "/output"]

# setup locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8

# install whipper
RUN mkdir /whipper
COPY . /whipper/
RUN cd /whipper && pip install --no-cache-dir --no-deps --break-system-packages . \
    && rm -rf /whipper \
    && whipper -v

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US
ENV LANGUAGE=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

USER worker
WORKDIR /output
ENTRYPOINT ["whipper"]
