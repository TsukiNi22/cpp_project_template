FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    cmake \
    make \
    git \
    pkg-config \
    python3 \
    gnupg \
    wget \
    && wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 18 \
    && ln -sf /usr/bin/clang-18 /usr/bin/clang \
    && ln -sf /usr/bin/clang++-18 /usr/bin/clang++ \
    && rm -rf /var/lib/apt/lists/* llvm.sh

ENV CC=clang
ENV CXX=clang++

WORKDIR /workspace
