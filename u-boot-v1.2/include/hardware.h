#ifndef __HARDWARE_H__
#define __HARDWARE_H__

//SYSTEM CONFIG
#define HW_PRESETCTRL0        0x80040000
#define HW_PRESETCTRL1        0x80040010
#define HW_AHBCLKCTRL0        0x80040020
#define HW_AHBCLKCTRL1        0x80040030
#define HW_SYSTCKCAL          0x80040040
#define HW_SYSPLLCTRL         0x80040100
#define HW_SYSPLLSTAT         0x80040104
#define HW_SYSRSTSTAT         0x80040110
#define HW_MAINCLKSEL         0x80040120
#define HW_MAINCLKUEN         0x80040124
#define HW_I2S0CLKSEL         0x80040130
#define HW_I2S0CLKUEN         0x80040134
#define HW_I2S1CLKSEL         0x80040138
#define HW_I2S1CLKUEN         0x8004013C
#define HW_USBCLKSEL          0x80040140
#define HW_USBCLKUEN          0x80040144
#define HW_WDTCLKSEL          0x80040160
#define HW_WDTCLKUEN          0x80040164
#define HW_OUTCLKSEL          0x80040170
#define HW_OUTCLKUEN          0x80040174
#define HW_CPUCLKDIV          0x8004017C
#define HW_SYSAHBCLKDIV       0x80040180
#define HW_I2S1_MCLKDIV       0x80040188
#define HW_I2S1_SCLKDIV	      0x8004018C	
#define HW_I2S0_MCLKDIV       0x80040190
#define HW_I2S0_SCLKDIV       0x80040194
#define HW_UART0CLKDIV        0x80040198
#define HW_UART1CLKDIV        0x8004019C
#define HW_UART2CLKDIV        0x800401A0
#define HW_UART3CLKDIV        0x800401A4
#define HW_UART4CLKDIV        0x800401A8
#define HW_UART5CLKDIV        0x800401AC
#define HW_UART6CLKDIV        0x800401B0
#define HW_UART7CLKDIV        0x800401B4
#define HW_UART8CLKDIV        0x800401B8
#define HW_UART9CLKDIV        0x800401BC
#define HW_SPI0CLKDIV         0x800401C0
#define HW_SPI1CLKDIV         0x800401C4
#define HW_QUADSPI0CLKDIV     0x800401C8
#define HW_SSP0CLKDIV         0x800401D0
#define HW_NANDCLKDIV         0x800401D4
#define HW_TRACECLKDIV        0x800401E0
#define HW_CAMMCLKDIV         0x800401E8
#define HW_WDTCLKDIV          0x800401EC
#define HW_USBCLKDIV          0x800401F0
#define HW_OUTCLKDIV          0x800401F4
#define HW_PDRUNCFG           0x80040238
#define HW_MATRIXPRI0         0x80040300
#define HW_MATRIXPRI1         0x80040304
#define HW_MATRIXPRI2         0x80040308
#define HW_MATRIXPRI3         0x8004030C
#define HW_MATRIXPRI4         0x80040310
#define HW_MATRIXPRI5         0x80040314
#define HW_MATRIXPRI6         0x80040318
#define HW_MATRIXPRI7         0x8004031C
#define HW_MATRIXPRI8         0x80040320
#define HW_MATRIXPRI9         0x80040324
#define HW_MATRIXPRI10        0x80040328
#define HW_MATRIXPRI11        0x8004032C
#define HW_MATRIXPRI12        0x80040330
#define HW_MATRIXPRI13        0x80040334
#define HW_MATRIXPRI14        0x80040338
#define HW_MATRIXPRI15        0x8004033C
#define HW_EMI_CTRL           0x8004034C
#define HW_RISC_CTRL          0x80040350
#define HW_MACPHY_SEL         0x80040360
#define HW_USB_CTRL           0x80040368
#define HW_DEVICEID           0x80040400
#define HW_PCON_ADDR          0x80040500
#define HW_DMA_CTRL	      0x80040354

#endif  /* __HARDWARE_H__ */