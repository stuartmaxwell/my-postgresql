# Declare build args
ARG PG_MAJOR=18

# Use the specific PostGIS image based on PG_MAJOR
FROM postgis/postgis:$PG_MAJOR-3.6

# Re-declare for scope within this stage
ARG PG_MAJOR

# Fetch pgvector source code
ADD https://github.com/pgvector/pgvector.git#v0.8.1 /tmp/pgvector

# Install build tools and dependencies
RUN apt-get update && \
    apt-mark hold locales && \
    apt-get install -y --no-install-recommends \
        build-essential \
        postgresql-server-dev-$PG_MAJOR \
    && cd /tmp/pgvector \
    && make clean \
    && make OPTFLAGS="" \
    && make install \
    && mkdir -p /usr/share/doc/pgvector \
    && cp LICENSE README.md /usr/share/doc/pgvector \
    && rm -r /tmp/pgvector \
    && apt-get remove -y build-essential postgresql-server-dev-$PG_MAJOR \
    && apt-get autoremove -y \
    && apt-mark unhold locales \
    && rm -rf /var/lib/apt/lists/*
