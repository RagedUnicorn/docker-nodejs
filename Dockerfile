############################################
# Node.js runtime image
############################################
FROM alpine:3.24.2

# renovate: datasource=repology depName=alpine_3_24/nodejs versioning=loose
ARG NODEJS_VERSION=24.18.1-r0
# renovate: datasource=repology depName=alpine_3_24/npm versioning=loose
ARG NPM_VERSION=11.12.1-r0
ARG BUILD_DATE
ARG VERSION

# OCI-compliant labels
LABEL org.opencontainers.image.title="Node.js on Alpine Linux" \
      org.opencontainers.image.description="Minimal Node.js Docker image with npm built on Alpine Linux" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/ragedunicorn/docker-nodejs" \
      org.opencontainers.image.documentation="https://github.com/ragedunicorn/docker-nodejs/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.2"

# Node.js LTS from the Alpine main repository, npm from the Alpine community
# repository. nodejs and npm are separate aports with independent versions,
# so each carries its own pin. ca-certificates provides the TLS trust store
# (family convention; npm needs it for registry HTTPS requests).
RUN apk add --no-cache \
    ca-certificates \
    nodejs=${NODEJS_VERSION} \
    npm=${NPM_VERSION}

# Create non-root user for running Node.js. A home directory is created
# deliberately (no -H): npm wants a writable ~/.npm cache directory and
# warns on every run without one.
RUN adduser -D -s /sbin/nologin node

WORKDIR /app

RUN chown -R node:node /app

USER node

ENTRYPOINT ["node"]

CMD ["-i"]
