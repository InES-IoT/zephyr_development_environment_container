# Zephyr Development Environment Container

The `Containerfile` builds a development environment image that allows compiling
and flashing Zephyr applications. The following instructions use `podman` but
`docker` also works.

As of now flashing is only supported with a J-Link debugger.

## Build Container Image

This example builds a Zephyr v3.5.0 image for stm32 targets and includes the
LVGL graphics library and the SEGGER SystemView and RTT libraries.

``` shell
podman build \
  --file=Containerfile \
  --build-arg="ZEPHYR_VERSION=3.5.0" \
  --build-arg="SDK_VERSION=0.16.3" \
  --build-arg="MODULES=cmsis hal_stm32 lvgl segger" \
  . -t zephyr_stm32_v3.5.0
```

If the `MODULES` argument is omitted all Zephyr modules will be installed.

This works for SDK versions `0.16.0` and newer. Run the following to make the
image build work for versions `0.14.0` to `0.15.2`.

``` shell
sed -i "s/\.tar\.xz/\.tar\.gz/" Containerfile
```

## Export Container Image

``` shell
podman save zephyr_stm32_v3.5.0 | zstd -T0 -19 > zephyr_stm32_v3.5.0.tar.zst
```

Use `gzip` if `zstd` is not available.

## Import Container Image

``` shell
podman load --input zephyr_stm32_v3.5.0.tar.zst
```

## Use Container as WSL2 Distro

See https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro for reference.

Export file system of container:

``` shell
cid=$(podman create zephyr_stm32_v3.5.0)
podman export $cid | zstd -T0 -19 > zephyr_stm32_v3.5.0_wsl.tar.zst
podman rm $cid
```

Import file system as WSL2 distro on Windows:

``` powershell
mkdir wslDistroStorage\zephyr_v3.5.0
wsl --import zephyr_v3.5.0 wslDistroStorage\zephyr_v3.5.0 zephyr_v3.5.0_wsl.tar.zst
wsl -d zephyr
```

# Instructions for Users

see [Instructions](./instructions)
