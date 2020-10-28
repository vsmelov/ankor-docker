FROM ubuntu:18.04
LABEL maintainer="vladimirfol@gmail.com" \
      vendor="Individual Entrepreneur Vladimir Smelov" \
      version="0.0.1" \
      description="Samtools and biobambam2"

############ VERSIONS ############

ENV LIBDEFLATE_VERSION="v1.6" \
    SAMTOOLS_VERSION="1.11" \
    BIOBAMBAM_VERSION="2.0.146-release-20191030105216" \
    GMP_VERSION="6.2.0" \
    LIBMAUS_VERSION="2.0.683-release-20191030103256"

# somehow biobabam2 does not compile with the latest libmaus2 version :-(
# LIBMAUS_VERSION="2.0.760-release-20201023104034"

############ BUILD SOFTWARE ############

# Install build requirements
RUN apt-get update -y && \
    apt-get install -y \
        build-essential \
        git \
        wget \
        autotools-dev \
        autoconf \
        libbz2-dev \
        libncurses5-dev \
        liblzma-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
        pkg-config \
        lzip \
        libtool \
        automake \
        m4 \
        gcc-8 \
        g++-8


############ BUILD SETTINGS ############

ENV PREFIX="/soft"
ENV PATH=${PATH}:${PREFIX}/bin
ENV CC="gcc-8"
ENV CXX="g++-8"
ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV CFLAGS="-I$PREFIX/include $CFLAGS -fPIC -O2"
ENV CXXFLAGS="-I$PREFIX/include -lstdc++fs $CXXFLAGS -fPIC -O2"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"

# Create folder for soft
RUN mkdir -p $PREFIX

# Install libdeflate
RUN git clone --depth=1 --branch="$LIBDEFLATE_VERSION" https://github.com/ebiggers/libdeflate.git && \
    cd libdeflate && \
    make -j${JOBS} install PREFIX=$PREFIX && \
    cd .. && \
    rm -rf libdeflate

# Install zlib
RUN git clone https://github.com/cloudflare/zlib cloudflare-zlib && \
    cd cloudflare-zlib && \
    ./configure --prefix=$PREFIX && \
    make -j${JOBS} install && \
    cd .. && \
    rm -rf cloudflare-zlib

# Install samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    tar jxf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
	rm -f samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    cd samtools-${SAMTOOLS_VERSION} && \
	./configure --prefix=$PREFIX --with-libdeflate && \
    make -j${JOBS} install all-htslib && \
    cd .. && \
    rm -rf samtools-${SAMTOOLS_VERSION}

# Install gmp
RUN wget https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.lz && \
    tar --lzip -xf gmp-$GMP_VERSION.tar.lz && \
    rm -f gmp-$GMP_VERSION.tar.lz && \
    cd gmp-$GMP_VERSION && \
    ./configure --enable-cxx --prefix=$PREFIX && \
    make -j${JOBS} && \
    make check && \
    make install && \
    cd .. && \
    rm -rf gmp-$GMP_VERSION

# Install libmaus
ENV CXXFLAGS="-I$PREFIX/include -fPIC -O2 -std=c++11 -lstdc++fs"
RUN wget https://gitlab.com/german.tischler/libmaus2/-/archive/$LIBMAUS_VERSION/libmaus2-$LIBMAUS_VERSION.tar.gz && \
    tar -xzf libmaus2-$LIBMAUS_VERSION.tar.gz && \
    rm -f libmaus2-$LIBMAUS_VERSION.tar.gz && \
    cd libmaus2-$LIBMAUS_VERSION  && \
    ./configure --prefix=$PREFIX --with-gmp=$PREFIX && \
    make -j4 install && \
    cd .. && \
    rm -rf libmaus2-$LIBMAUS_VERSION

# Install biobambam2
ENV LDFLAGS="-Wl,-rpath=XORIGIN/../lib -Wl,-z -Wl,origin $LDFLAGS"
RUN wget https://gitlab.com/german.tischler/biobambam2/-/archive/$BIOBAMBAM_VERSION/biobambam2-$BIOBAMBAM_VERSION.tar.gz && \
    tar -xzf biobambam2-${BIOBAMBAM_VERSION}.tar.gz && \
    rm -f biobambam2-${BIOBAMBAM_VERSION}.tar.gz && \
    cd biobambam2-${BIOBAMBAM_VERSION} && \
    autoreconf -i -f && \
    ./configure --prefix=$PREFIX --with-libmaus2=${PREFIX} && \
    make -j4 install && \
    cd .. && \
    rm -rf biobambam2-${BIOBAMBAM_VERSION}
