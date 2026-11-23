# Pinned toolchain image for make check-docker (and the reference for CI).
# The base image pin lives in tools.versions (CHECK_IMAGE); the Makefile passes it in.
# Build: make check-docker. Nothing here is published to a registry.
ARG CHECK_IMAGE=missing-set-CHECK_IMAGE-via-make
FROM ${CHECK_IMAGE}

ENV TOOLS_DIR=/opt/tools
COPY tools.versions package.json package-lock.json requirements-lint.txt /opt/src/
COPY scripts/lib.sh scripts/install-tools.sh scripts/doctor.sh /opt/src/scripts/
RUN /opt/src/scripts/install-tools.sh --with-os-packages

ENV PATH=/opt/tools/bin:/opt/tools/node/bin:/opt/tools/npm/node_modules/.bin:/opt/tools/venv/bin:${PATH}
