FROM debian

RUN apt-get update -y && apt-get install -y \
  autoconf \
  automake \
  autopoint \
  gawk \
  git \
  gnutls-bin \
  libpq-dev \
  libtool \
  make \
  postgresql-client-common \
  strace \
  texinfo \
  g++ \
  rapidjson-dev \
  libhiredis-dev \
  libgd-dev \
  pkg-config \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Install gdlib-config wrapper script
COPY scripts/gdlib-config /usr/local/bin/gdlib-config
RUN chmod +x /usr/local/bin/gdlib-config

RUN git clone --depth 1 https://github.com/yammerjp/gawkextlib /gawk-pgsql/gawkextlib

WORKDIR /gawk-pgsql/gawkextlib

RUN ./build.sh lib
RUN ./build.sh pgsql --with-libpq=/usr/include/postgresql
RUN ./build.sh json
RUN ./build.sh redis

# Copy and apply patch for gd extension (API compatibility + circular crop feature)
COPY patches/gd_circular_crop.patch /gawk-pgsql/gawkextlib/
RUN cd gd && patch -p2 < ../gd_circular_crop.patch

# Build gd with build.sh (ldconfig is run before tests to ensure libraries are found)
RUN ldconfig && ./build.sh gd

# COPY entrypoint.sh /entrypoint.sh
# COPY testpgsql.awk /testpgsql.awk
ENV AWKLIBPATH=/usr/local/lib/gawk \
    LD_LIBRARY_PATH=/usr/local/lib
# ENTRYPOINT ["/entrypoint.sh"]
