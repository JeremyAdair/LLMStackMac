FROM tsl0922/ttyd:1.7.7

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tmux ca-certificates \
    && rm -rf /var/lib/apt/lists/*
