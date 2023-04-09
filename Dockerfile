# syntax=docker/dockerfile:1.4
#######################################################
# APP_TARGET: full
#
# All of the dev/test/build tools
#######################################################
FROM ghcr.io/gostamp/ubuntu-full:0.4.0 AS full

# Copy app source
COPY . ${APP_DIR}

ENTRYPOINT ["/app/bin/entrypoint.sh"]
CMD ["/app/bin/run.sh"]

#######################################################
# APP_TARGET: slim
#
# A minimal image w/ just the app
#######################################################
FROM ghcr.io/gostamp/ubuntu-slim:0.4.0 AS slim

COPY --from=full ${APP_DIR} ${APP_DIR}

ENTRYPOINT ["/app/bin/entrypoint.sh"]
CMD ["/app/bin/run.sh"]
