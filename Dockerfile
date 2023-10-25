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
ARG JLINK_VERSION=V792k

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

# Install pyhton dependencies
RUN pip install --break-system-packages west pyelftools && \
	echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc

# Init the Zephyr workspace
RUN west init -m https://github.com/zephyrproject-rtos/zephyr --mr v3.5.0 zephyrproject && \
	cd zephyrproject && \
	west update && \
	west zephyr-export && \
	echo 'source /root/zephyrproject/zephyr/zephyr-env.sh' >> ~/.bashrc

RUN	apt-get -y update && \
	apt-get install --no-install-recommends -y curl

# Get and install the J-Link software pack
RUN curl -O -d accept_license_agreement=accepted -d non_emb_ctr=confirmed https://www.segger.com/downloads/jlink/JLink_Linux_${JLINK_VERSION}_x86_64.deb && \
	dpkg --ignore-depends=\
libxrender1,\
libxcb-render0,\
libxcb-render-util0,\
libxcb-shape0,\
libxcb-randr0,\
libxcb-xfixes0,\
libxcb-sync1,\
libxcb-shm0,\
libxcb-icccm4,\
libxcb-keysyms1,\
libxcb-image0,\
libxkbcommon0,\
libxkbcommon-x11-0,\
libfontconfig1,\
libfreetype6,\
libxext6,\
libx11-6,\
libxcb1,\
libx11-xcb1,\
libsm6,\
libice6,\
libglib2.0-0\
 --unpack JLink_Linux_V792k_x86_64.deb && \
	rm /var/lib/dpkg/info/jlink.postinst && \
	dpkg --ignore-depends=\
libxrender1,\
libxcb-render0,\
libxcb-render-util0,\
libxcb-shape0,\
libxcb-randr0,\
libxcb-xfixes0,\
libxcb-sync1,\
libxcb-shm0,\
libxcb-icccm4,\
libxcb-keysyms1,\
libxcb-image0,\
libxkbcommon0,\
libxkbcommon-x11-0,\
libfontconfig1,\
libfreetype6,\
libxext6,\
libx11-6,\
libxcb1,\
libx11-xcb1,\
libsm6,\
libice6,\
libglib2.0-0\
 --configure jlink && \
	apt-get install -fy && \
	rm JLink_Linux_V792k_x86_64.deb

WORKDIR /root/zephyrproject

RUN west build -b nrf52840dk_nrf52840 zephyr/samples/basic/blinky
