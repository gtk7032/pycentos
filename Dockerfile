FROM centos:centos8.4.2105

# ARG CRT=/path/to/hoge.crt
# COPY ${CRT} /usr/share/pki/ca-trust-source/anchors
# RUN update-ca-trust extract

ARG VER=3.10.13

RUN cd /usr/local \
    && sed -i '/^mirrorlist/c baseurl=http://vault.centos.org/$contentdir/$releasever/BaseOS/$basearch/os/' /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
    && sed -i '/^mirrorlist/c baseurl=http://vault.centos.org/$contentdir/$releasever/AppStream/$basearch/os/' /etc/yum.repos.d/CentOS-Linux-AppStream.repo \
    && dnf update -y \ 
    && dnf groupinstall -y "development tools" \
    && dnf install -y bzip2-devel gdbm-devel libffi-devel libuuid-devel ncurses-devel openssl-devel readline-devel sqlite-devel xz-devel zlib-devel \
    && curl -O https://www.python.org/ftp/python/${VER}/Python-${VER}.tar.xz \
    && tar xJf Python-${VER}.tar.xz \
    && rm -f Python-${VER}.tar.xz \
    && cd Python-${VER} \
    && ./configure --enable-shared \
    && make \
    && make install \
    && ln -s /usr/local/lib/libpython3.10.so.1.0 /lib64/libpython3.10.so.1.0 \
    && dnf clean all

ENV PATH="/usr/local/Python-$VER:$PATH"
ARG PRJ=pycentos
ARG PRJ_DIR=/usr/local/${PRJ}
COPY ./requirements.txt /tmp
RUN mkdir -p ${PRJ_DIR} \
    && cd ${PRJ_DIR} \
    && python -m pip install -r /tmp/requirements.txt --no-cache-dir \
    && rm -f /tmp/requirements.txt

WORKDIR "$PRJ_DIR"
