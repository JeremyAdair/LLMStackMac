FROM alpine:3.19

ARG WORKSPACE_UID=1000
ARG WORKSPACE_GID=1000

RUN addgroup -g ${WORKSPACE_GID} workspace \
  && adduser -D -u ${WORKSPACE_UID} -G workspace workspace \
  && apk add --no-cache bash ca-certificates coreutils curl git openssh-client

USER workspace
WORKDIR /workspace
