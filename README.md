# Zephyr Development Environment Container

`podman` can be replaced with `docker` in each of the following commands.

## Build Container Image

The following builds a Zephyr 3.5.0 image for stm32 targets.

``` shell
podman build \
	--build-arg="ZEPHYR_VERSION=3.5.0" \
	--build-arg="SDK_VERSION=0.16.3" \
	--build-arg="MODULES=cmsis hal_stm32" \
	. -t zephyr_stm32_v3.5.0
```

If the `MODULES` argument is omitted all Zephyr modules will be installed.

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
podman export $cid | gzip > zephyr_wsl.tar.gz
podman rm $cid
```

``` powershell
mkdir wslDistroStorage\zephyr
wsl --import zephyr wslDistroStorage\zephyr zephyr_wsl.tar.gz
wsl -d zephyr_stm32_v3.5.0
```

