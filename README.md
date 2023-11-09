# Zephyr Development Environment Container

The `Containerfile` contains instructions for building a development environment
image that allows compiling and flashing Zephyr applications. As of now flashing
is only supported with a J-Link debugger.

The following instructions use `podman` but `docker` should also work.

## Build Container Image

This example builds a Zephyr v3.5.0 image for stm32 targets and includes the
LVGL graphics library and the SEGGER SystemView and RTT libraries.

``` shell
podman build \
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
podman save zephyr_stm32_v3.5.0 | gzip > zephyr_stm32_v3.5.0.tar.gz
```

Using `xz` instead of `gzip` results in a much smaller file but longer
compression and decompression times.

## Import Container Image

``` shell
podman load --input zephyr_stm32_v3.5.0.tar.gz
```

## Use Container as WSL2 Distro

https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro

``` shell
cid=$(podman create zephyr_stm32_v3.5.0)
podman export $cid | gzip > zephyr_stm32_v3.5.0_wsl.tar.gz
podman rm $cid
```

``` powershell
mkdir wslDistroStorage\zephyr
wsl --import zephyr wslDistroStorage\zephyr zephyr_wsl.tar.gz
wsl -d zephyr_stm32_v3.5.0
```
