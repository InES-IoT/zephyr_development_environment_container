# Zephyr Development Environment Container

The `Containerfile` builds a development environment image that allows compiling
and flashing Zephyr applications. The following instructions use `podman` but
`docker` also works.

As of now flashing is only supported with a J-Link debugger.

## Build Container Image

This example builds a Zephyr v4.2.0 image for Nordic targets that includes
`mbedtls` and `mcuboot` as well as the Segger *SystemView* and *RTT* libraries.

``` shell
podman build \
  --file=Containerfile \
  --build-arg="ZEPHYR_VERSION=4.2.0" \
  --build-arg="SDK_VERSION=0.17.2" \
  --build-arg="MODULES=cmsis_6 hal_nordic mbedtls mcuboot segger" \
  --build-arg="ADDITIONAL_PYTHON_PACKAGES=imgtool" \
  --build-arg="ADDITIONAL_APT_PACKAGES=xxd binutils" \
  . -t zephyr_nrf_v4.2.0
```

> Use `cmsis` instead of `cmsis_6` for Zephyr versions before 4.2.

If the `MODULES` argument is omitted all Zephyr modules will be installed.

The `ADDITIONAL_PYTHON_PACKAGES` and `ADDITIONAL_APT_PACKAGES` arguments can be
omitted but some default packages will still be installed.

This works for SDK versions `0.16.0` and newer. Run the following to make the
image build work for versions `0.14.2` to `0.15.2`.

``` shell
sed -i "s/\.tar\.xz/\.tar\.gz/" Containerfile
```

> A matrix that shows which Zephyr version is compatible with which SDK version can be found on the [Zephyr GitHub wiki](https://github.com/zephyrproject-rtos/sdk-ng/wiki/Zephyr-SDK-Version-Compatibility-Matrix).

## Export Container Image

``` shell
podman save zephyr_nrf_v4.2.0 | zstd -T0 -19 > zephyr_nrf_v4.2.0.tar.zst
```

If `zstd` is not available, use `gzip` and change the file ending to `.tar.gz`.

## Import Container Image

``` shell
podman load --input zephyr_nrf_v4.2.0.tar.zst
```

## Use Container as WSL2 Distro

See https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro for reference.

Export file system of container:

``` shell
cid=$(podman create zephyr_nrf_v4.2.0)
podman export $cid | zstd -T0 -19 > zephyr_nrf_v4.2.0_wsl.tar.zst
podman rm $cid
```

Import file system as WSL2 distro on Windows:

``` powershell
mkdir C:\WSL\zephyr_v4.2.0
wsl --import zephyr_v4.2.0 C:\WSL\zephyr_v4.2.0 zephyr_v4.2.0_wsl.tar.zst
wsl -d zephyr_v4.2.0
```

# Instructions for Users

see [Instructions](./instructions)

# Literature

- https://interrupt.memfault.com/blog/wsl2-for-firmware-development
- https://interrupt.memfault.com/blog/comparing-fw-dev-envs
