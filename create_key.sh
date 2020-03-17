#!/usr/bin/env bash

# Generate key file
bundle exec ruby -r 'securerandom' \
    -e "File.write(File.join(Teneo::IngestServer::ROOT_DIR, 'key.bin'), SecureRandom.random_bytes(64), mode: 'wb')"
