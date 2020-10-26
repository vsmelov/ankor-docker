FROM ubuntu:18.04
ENV PREFIX="/soft"
ENV SAMTOOLS_VERSION="1.11"

RUN mkdir -p $PREFIX
ENV PATH=${PATH}:${PREFIX}/bin
RUN apt-get update -y
RUN apt-get install -y build-essential git wget

RUN apt-get install -y autotools-dev
RUN apt-get install -y autoconf
RUN apt-get install -y libbz2-dev libncurses5-dev liblzma-dev libcurl4-gnutls-dev
RUN apt-get install -y libssl-dev

RUN apt-get install -y gcc-8 g++-8
ENV CC="gcc-8"
ENV CXX="g++-8"
#ENV CXXFLAGS = "-std=c++11 -lstdc++fs $CXXFLAGS"
#ENV CXXFLAGS = "-std=c++11 $CXXFLAGS"
ENV CXXFLAGS="-lstdc++fs $CXXFLAGS"


# libdeflate
ENV LIBDEFLATE_VERSION="v1.6"
RUN git clone --depth=1 --branch="$LIBDEFLATE_VERSION" https://github.com/ebiggers/libdeflate.git && \
    cd libdeflate && make -j4 CFLAGS='-fPIC -O2' && make install PREFIX=$PREFIX && \
    cd .. && rm -rf libdeflate

# zlib
RUN git clone https://github.com/cloudflare/zlib cloudflare-zlib && \
    cd cloudflare-zlib && ./configure --prefix=$PREFIX && make install && \
    cd .. && \
    rm -rf cloudflare-zlib

RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2


ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV CFLAGS="-I$PREFIX/include $CFLAGS -fPIC -O2"
ENV CXXFLAGS="-I$PREFIX/include $CXXFLAGS -fPIC -O2"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PREFIX/lib

#ENV HTSLIB_VERSION="1.11.0"
#RUN git clone --branch="$HTSLIB_VERSION" --depth=1 https://github.com/samtools/htslib
#RUN cd htslib && autoheader && autoconf && \
#    ./configure --with-libdeflate && \
#    make -j4 install

## samtools
RUN tar jxf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
	rm samtools-${SAMTOOLS_VERSION}.tar.bz2
RUN cd samtools-${SAMTOOLS_VERSION} && \
	./configure --prefix=$PREFIX --with-libdeflate
RUN cd samtools-${SAMTOOLS_VERSION} && \
    make -j4 install all-htslib


RUN apt-get install -y pkg-config


# Build libmaus
RUN apt-get install -y libtool
RUN apt-get -y install m4 automake
#ENV LIBMAUS_VERSION="2.0.760-release-20201023104034"
#RUN git clone --branch="$LIBMAUS_VERSION" --depth=1 https://gitlab.com/german.tischler/libmaus2.git libmaus
##ENV CXXFLAGS="$CXXFLAGS -lstdc++fs"
##ENV CFLAGS="$CFLAGS -lstdc++fs"
##ENV CXX="g++-8"
##ENV CC="gcc-8"
#RUN cd libmaus && \
#    libtoolize && aclocal && autoheader && automake --force-missing --add-missing  && autoreconf -i -f && \
#    ./configure --prefix=$PREFIX &&  make -j4 install && cd .. && rm -rf libmaus

ENV GMP_VERSION="6.2.0"
RUN wget https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.lz
RUN apt-get install -y lzip
RUN tar --lzip -xf gmp-$GMP_VERSION.tar.lz
RUN cd gmp-$GMP_VERSION && ./configure --enable-cxx --prefix=$PREFIX && make -j4 && make check && make install && cd .. && rm -rf gmp-$GMP_VERSION

#RUN git clone https://gitlab.com/german.tischler/libmaus2.git \
# && cd libmaus2  \
# && libtoolize \
# && aclocal  \
# && autoheader       \
# && automake --force-missing --add-missing   \
# && autoconf \
# && ./configure --prefix=$PREFIX --with-gmp=$PREFIX \
# && make -j4 install

ENV CXXFLAGS="-I$PREFIX/include -fPIC -O2 -std=c++11 -lstdc++fs"
#ENV LIBMAUS_VERSION="2.0.760-release-20201023104034"
#ENV LIBMAUS_VERSION="2.0.731-release-20200720132414"
ENV LIBMAUS_VERSION="2.0.431-release-20171214130550"
RUN wget https://gitlab.com/german.tischler/libmaus2/-/archive/$LIBMAUS_VERSION/libmaus2-$LIBMAUS_VERSION.tar.gz
RUN tar -xzf libmaus2-$LIBMAUS_VERSION.tar.gz
RUN cd libmaus2-$LIBMAUS_VERSION  \
 && ./configure --prefix=$PREFIX --with-gmp=$PREFIX \
 && make -j4 install \
 && cd .. && rm -rf libmaus2-$LIBMAUS_VERSION

#ENV LIBMAUS_VERSION="2.0.760-release-20201023104034"
#RUN wget https://gitlab.com/german.tischler/libmaus2/-/archive/$LIBMAUS_VERSION/libmaus2-$LIBMAUS_VERSION.tar.gz
#RUN tar -xzf libmaus2-$LIBMAUS_VERSION.tar.gz
##RUN git clone https://gitlab.com/german.tischler/libmaus2.git
#RUN cd libmaus2-$LIBMAUS_VERSION  \
# && libtoolize \
# && aclocal \
# && autoreconf -i -f \
# && ./configure --prefix=$PREFIX --with-gmp=$PREFIX \
# && make -j4 install \
# && cd .. && rm -rf libmaus2-$LIBMAUS_VERSION

#ENV CXXFLAGS = "-std=c++11 -lstdc++fs $CXXFLAGS"
#ENV CXXFLAGS = "-std=c++11 $CXXFLAGS"
#ENV CXXFLAGS="-std=c++11 -lstdc++fs $CXXFLAGS"
#ENV CXXFLAGS="-I$PREFIX/include -fPIC -O2 -std=c++11 -lstdc++fs"


# biobambam2
#ENV BIOBAMBAM_VERSION="2.0.146-release-20191030105216"
ENV BIOBAMBAM_VERSION="2.0.82-release-20171214120547"
ENV LDFLAGS="-Wl,-rpath=XORIGIN/../lib -Wl,-z -Wl,origin $LDFLAGS"
RUN wget https://gitlab.com/german.tischler/biobambam2/-/archive/$BIOBAMBAM_VERSION/biobambam2-$BIOBAMBAM_VERSION.tar.gz
RUN tar -xzf biobambam2-${BIOBAMBAM_VERSION}.tar.gz
RUN cd biobambam2-${BIOBAMBAM_VERSION} && \
    autoreconf -i -f && \
    ./configure --prefix=$PREFIX --with-libmaus2=${PREFIX} && \
    make -j4 install && \
    cd .. && \
    rm -rf biobambam2-${BIOBAMBAM_VERSION}

#
#
#LABEL maintainer="vladimirfol@gmail.com" \
#      vendor="Individual Entrepreneur Vladimir Smelov" \
#      version="0.0.1" \
#      description="Samtools and biobambam2"
