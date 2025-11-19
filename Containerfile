#  _____       ______   ____
# |_   _|     |  ____|/ ____|  Institute of Embedded Systems
#   | |  _ __ | |__  | (___    Zurich University of Applied Sciences
#   | | | '_ \|  __|  \___ \   8401 Winterthur, Switzerland
#  _| |_| | | | |____ ____) |
# |_____|_| |_|______|_____/
#
# Copyright 2025 Institute of Embedded Systems at Zurich University of Applied Sciences.
# All rights reserved.
# SPDX-License-Identifier: MIT

FROM debian:12-slim

# Set non-interactive frontend for apt-get to skip any user confirmations
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
ARG ADDITIONAL_APT_PACKAGES=""
RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install --no-install-recommends -y \
	python3-pip \
	git \
	cmake \
	device-tree-compiler \
	wget \
	xz-utils \
	ninja-build \
	${ADDITIONAL_APT_PACKAGES}

# Install Zephyr SDK
ARG SDK_VERSION
RUN test -n "${SDK_VERSION}" || (echo "SDK_VERSION build argument not set" && false)
WORKDIR /opt/toolchains
RUN HOST_ARCHITECTURE=$(uname -m) && \
	wget --quiet -O sdk.tar.xz https://github.com/zephyrproject-rtos/sdk-ng/releases/download/\
v"${SDK_VERSION}"/zephyr-sdk-"${SDK_VERSION}"_linux-"${HOST_ARCHITECTURE}"_minimal.tar.xz && \
	tar -xf sdk.tar.xz && \
	rm sdk.tar.xz && \
	cd zephyr-sdk-"${SDK_VERSION}" && \
	wget --quiet -O toolchain.tar.xz https://github.com/zephyrproject-rtos/sdk-ng/releases/download/\
v"${SDK_VERSION}"/toolchain_linux-"${HOST_ARCHITECTURE}"_arm-zephyr-eabi.tar.xz && \
	tar -xf toolchain.tar.xz && \
	./setup.sh -t arm-zephyr-eabi -c && \
	rm toolchain.tar.xz zephyr-*.sh

# Clean up stale packages
RUN apt-get clean -y && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

# Init the Zephyr workspace
ARG ZEPHYR_VERSION
RUN test -n "${ZEPHYR_VERSION}" || (echo "ZEPHYR_VERSION build argument not set" && false)
ARG MODULES=""
WORKDIR /root/zephyrproject
RUN pip install --break-system-packages west
RUN git clone --branch v${ZEPHYR_VERSION} --depth=1 \
	https://github.com/zephyrproject-rtos/zephyr && \
	west init --local zephyr && \
	west update --narrow --fetch-opt=--depth=1 ${MODULES} && \
	echo "source \"$(pwd)/zephyr/zephyr-env.sh\"" >> ~/.bashrc

# Install Python dependencies
ARG ADDITIONAL_PYTHON_PACKAGES=""
RUN pip install --break-system-packages -r zephyr/scripts/requirements-base.txt ${ADDITIONAL_PYTHON_PACKAGES} && \
	echo "export PATH=~/.local/bin:\"$PATH\"" >> ~/.bashrc

# Hack to make J-Link deb installation work
RUN ln -s "$(which true)" /usr/local/bin/udevadm

# Get and install the J-Link Software and Documentation Pack
RUN HOST_ARCHITECTURE=$(uname -m) && \
	if [ "${HOST_ARCHITECTURE}" = "aarch64" ]; then HOST_ARCHITECTURE="arm64"; fi && \
	wget --quiet --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed' \
	https://www.segger.com/downloads/jlink/JLink_Linux_${HOST_ARCHITECTURE}.deb && \
	dpkg --force-depends --install JLink_Linux_${HOST_ARCHITECTURE}.deb && \
	rm JLink_Linux_${HOST_ARCHITECTURE}.deb

WORKDIR /root/dev
CMD ["bash"]
