FROM debian:12-slim

# Set default shell during Docker image build to bash
SHELL ["/bin/bash", "-c"]

# Set non-interactive frontend for apt-get to skip any user confirmations
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install --no-install-recommends -y \
	python3-pip \
	git \
	cmake \
	device-tree-compiler \
	wget \
	xz-utils \
	openocd \
	ninja-build

# Install Zephyr SDK
ARG ZSDK_VERSION=0.16.3

RUN mkdir -p /opt/toolchains && \
	cd /opt/toolchains && \
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
	tar xf zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
	rm zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
	cd zephyr-sdk-${ZSDK_VERSION} && \
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/toolchain_linux-${HOSTTYPE}_arm-zephyr-eabi.tar.xz && \
	tar xf toolchain_linux-${HOSTTYPE}_arm-zephyr-eabi.tar.xz && \
	./setup.sh -t arm-zephyr-eabi -c && \
	rm toolchain_linux-${HOSTTYPE}_arm-zephyr-eabi.tar.xz zephyr-*.sh

# Clean up stale packages
RUN apt-get clean -y && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN pip install --break-system-packages west pyelftools && \
	echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc

RUN west init -m https://github.com/zephyrproject-rtos/zephyr --mr v3.5.0 zephyrproject && \
	cd zephyrproject && \
	west update && \
	west zephyr-export

WORKDIR /root/zephyrproject

RUN source zephyr/zephyr-env.sh && \
	west build -b nrf52840dk_nrf52840 zephyr/samples/basic/blinky
