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
	ninja-build

# Install Zephyr SDK
ARG SDK_VERSION
RUN test -n "${SDK_VERSION}" || (echo "SDK_VERSION build argument not set" && false)
WORKDIR /opt/toolchains
RUN HOSTTYPE=$(bash -c 'echo ${HOSTTYPE}') && \
	wget --quiet -O sdk.tar.xz https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/zephyr-sdk-${SDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
	tar -xf sdk.tar.xz && \
	rm sdk.tar.xz && \
	cd zephyr-sdk-${SDK_VERSION} && \
	wget --quiet -O toolchain.tar.xz https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/toolchain_linux-${HOSTTYPE}_arm-zephyr-eabi.tar.xz && \
	tar -xf toolchain.tar.xz && \
	./setup.sh -t arm-zephyr-eabi -c && \
	rm toolchain.tar.xz zephyr-*.sh

# Clean up stale packages
RUN apt-get clean -y && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

# Install python dependencies
RUN pip install --break-system-packages west pyelftools pylink-square && \
	echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc

# Init the Zephyr workspace
ARG ZEPHYR_VERSION
RUN test -n "${ZEPHYR_VERSION}" || (echo "ZEPHYR_VERSION build argument not set" && false)
ARG MODULES
WORKDIR /root/zephyrproject
RUN git clone --branch zephyr-v${ZEPHYR_VERSION} --depth=1 \
	https://github.com/zephyrproject-rtos/zephyr && \
	west init --local zephyr && \
	west update --narrow --fetch-opt=--depth=1 ${MODULES} && \
	echo 'source '$(pwd)'/zephyr/zephyr-env.sh' >> ~/.bashrc

# Hack to make J-Link deb installation work
RUN ln -s $(which true) /usr/local/bin/udevadm

# Get and install the J-Link Software and Documentation Pack
RUN HOSTTYPE=$(bash -c 'echo ${HOSTTYPE}') && \
	wget --quiet --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed' \
	https://www.segger.com/downloads/jlink/JLink_Linux_${HOSTTYPE}.deb && \
	dpkg --force-depends --install JLink_Linux_${HOSTTYPE}.deb && \
	rm JLink_Linux_${HOSTTYPE}.deb

WORKDIR /root/dev
CMD ["bash"]
