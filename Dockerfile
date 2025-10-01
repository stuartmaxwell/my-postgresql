# Declare build args
ARG POSTGRES_MAJOR_VER=18
ARG POSTGIS_VER=3.6
ARG PGVECTOR_VER=0.8.1

# Use the specific PostGIS image based on PG_MAJOR
FROM postgis/postgis:$POSTGRES_MAJOR_VER-$POSTGIS_VER

# Re-declare for scope within this stage
ARG POSTGRES_MAJOR_VER
ARG PGVECTOR_VER

# Fetch pgvector source code
ADD https://github.com/pgvector/pgvector.git#v$PGVECTOR_VER /tmp/pgvector

# Install build tools and dependencies
RUN apt-get update && \
    apt-mark hold locales && \
    apt-get install -y --no-install-recommends \
        build-essential \
        postgresql-server-dev-$POSTGRES_MAJOR_VER \
    && cd /tmp/pgvector \
    && make clean \
    && make OPTFLAGS="" \
    && make install \
    && mkdir -p /usr/share/doc/pgvector \
    && cp LICENSE README.md /usr/share/doc/pgvector \
    && rm -r /tmp/pgvector \
    && apt-get remove -y build-essential postgresql-server-dev-$POSTGRES_MAJOR_VER \
    && apt-get autoremove -y \
    && apt-mark unhold locales \
    && rm -rf /var/lib/apt/lists/*
