ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-buster

ARG PG_VERSION
ARG BUNDLER_VERSION

# Silence apt
RUN dpkg-reconfigure debconf --frontend=noninteractive

# Install common packages
RUN apt-get update -qq \
    && apt-get install -qy --no-install-recomends \
        build-essential \
        gnupg2 \
        curl \
        less \
        git \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Install PostgreSQL
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/postgres.list \
    && apt-get update -qq \
    && apt-get dist-upgrade -qy \
    && apt-get install -qy --no-install-recomends \
        libpq-dev \
        postgresql-client-$PG_VERSION \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle
COPY instantclient-basiclite-linux.x64-12.1.0.2.0.zip /opt/oracle/instantclient.zip
RUN cd /opt/oracle \
    && unzip -qq instantclient.zip \
    && rm instantclient.zip \
    && cd instantclient_12_1 \
    && ln -s libclntsh.so.12.1 libclntsh.so \
    && ln -s libocci.so.12.1 libocci.so \
    && apt-get install -qy --no-install-recomends libaio1 \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Install other dependencies
COPY Aptfile /tmp/Aptfile
RUN apt-get install -qy --no-install-recomends \
    $(cat /tmp/Aptfile | xargs) \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# Create a directory for the app code
RUN mkdir -p /app

WORKDIR /app
