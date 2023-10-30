FROM debian:12-slim

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
	ninja-build \
	curl

# Install Zephyr SDK
ARG ZEPHYR_VERSION=3.5.0
ARG ZSDK_VERSION=0.16.3

RUN HOSTTYPE=$(bash -c 'echo ${HOSTTYPE}') && \
	mkdir -p /opt/toolchains && \
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

# Install pyhton dependencies
RUN pip install --break-system-packages west pyelftools pylink-square && \
	echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc

# Init the Zephyr workspace
RUN west init -m https://github.com/zephyrproject-rtos/zephyr --mr v${ZEPHYR_VERSION} zephyrproject && \
	cd zephyrproject && \
	west update && \
	west zephyr-export && \
	echo 'source /root/zephyrproject/zephyr/zephyr-env.sh' >> ~/.bashrc

# Hack to make J-Link deb installation work
RUN ln -s $(which true) /usr/local/bin/udevadm

# Get and install the J-Link Software and Documentation Pack
RUN HOSTTYPE=$(bash -c 'echo ${HOSTTYPE}') && \
	curl -O -d accept_license_agreement=accepted -d non_emb_ctr=confirmed \
	https://www.segger.com/downloads/jlink/JLink_Linux_${HOSTTYPE}.deb && \
	dpkg --force-depends -i JLink_Linux_${HOSTTYPE}.deb && \
	rm JLink_Linux_${HOSTTYPE}.deb
