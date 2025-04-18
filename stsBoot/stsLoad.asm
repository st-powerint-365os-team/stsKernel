;over512stsLoadBooting (c) 2025 sungbly_tsstt
;At stsBoot
%include "stsBoot/ptmLoad.inc" 
%include "stsBoot/pm.inc"
org 0xc200
jmp _start
; GDT
;                            段基址     段界限, 属性
LABEL_GDT:	    Descriptor 0,            0, 0              ; 空描述符
LABEL_DESC_FLAT_C:  Descriptor 0,      0fffffh, DA_CR|DA_32|DA_LIMIT_4K ;0-4G
LABEL_DESC_FLAT_RW: Descriptor 0,      0fffffh, DA_DRW|DA_32|DA_LIMIT_4K;0-4G
LABEL_DESC_VIDEO:   Descriptor 0B8000h, 0ffffh, DA_DRW|DA_DPL3 ; 显存首地址

GdtLen		equ	$ - LABEL_GDT
GdtPtr		dw	GdtLen - 1				; 段界限
		dd	BaseOfLoaderPhyAddr + LABEL_GDT		; 基地址

; GDT 选择子
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3



BaseOfStack	equ	0100h
PageDirBase	equ	100000h	; 页目录开始地址: 1M
PageTblBase	equ	101000h	; 页表开始地址:   1M + 4K
_start:
    ; 设置屏幕模式为文本模式 3 (80x25 字符，16 颜色)
    mov ah, 00h
    mov al, 03h
    int 10h

    ; 清除屏幕
    call stConsole.clear

    ; 重置光标
    call stConsole.resetCursor

    mov dh, 0
    mov ax, stsLoadMessage
    mov cx, 18
    call stLogConsole.info

    add dh, 1
    mov ax, stsProtectModeLoadingMsg
    mov cx, 20
    call stLogConsole.info
    call protectModeLoader
while:
    hlt
    jmp while
protectModeLoader:
    ; 加载 GDTR
    lgdt	[GdtPtr]

    ; 关中断
    cli

    ; 打开地址线A20
    in	al, 92h
    or	al, 00000010b
    out	92h, al

    ; 准备切换到保护模式
    mov	eax, cr0
    or	eax, 1
    mov	cr0, eax

    ; 真正进入保护模式
    ; jmp	dword SelectorFlatC:(BaseOfLoaderPhyAddr+x86Start)
    ; jmp	x86Start

    jmp	$
    ret

stsLoadMessage:
    db "stsLoad Booting...", 0
stsProtectModeLoadingMsg:
    db "Loading protect Mode", 0
stsProtectedModeMsg:
    db "Protect mode loaded successfully", 0
; consoleLib
