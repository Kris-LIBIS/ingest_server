FROM libis/teneo-ruby:latest

ARG APP_DIR=/teneo

# Copy application data
COPY . ${APP_DIR}

# Switch to application user
WORKDIR ${APP_DIR}

# Application configuration
ARG API_PORT=3000
EXPOSE $API_PORT

# Run application
CMD ["puma", "-p", "$API_PORT", "-e", "$RUBY_ENV", "--log-requests"]
