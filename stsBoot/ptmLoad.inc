BaseOfLoader	    equ	 07c00h	; LOADER.BIN 被加载到的位置 ----  段地址
OffsetOfLoader	    equ	  0100h	; LOADER.BIN 被加载到的位置 ---- 偏移地址

BaseOfLoaderPhyAddr equ	BaseOfLoader*10h ; LOADER.BIN 被加载到的位置 ---- 物理地址

BaseOfKernelFile    equ	 0c200h	; KERNEL.BIN 被加载到的位置 ----  段地址
OffsetOfKernelFile  equ	     0h	; KERNEL.BIN 被加载到的位置 ---- 偏移地址