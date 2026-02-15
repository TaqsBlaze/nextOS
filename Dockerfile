FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    libncurses-dev \
    dwarves \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
