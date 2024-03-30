Install `GNU Make` and `XeLaTeX` and run the following command to build the pdf
files. Note that the value of these variables gets parsed by TeX (hence the `\_`).

``` shell
make ZEPHYRVERSION=3.6.0 SDKVERSION=0.16.5 MCU=STM32F429ZI BOARD=stm32f429i\\_disc1 IMAGENAME=embreal\\_zephyr\\_v\\zephyrversion{}
```
