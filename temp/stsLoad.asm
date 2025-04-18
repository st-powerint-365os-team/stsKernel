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

;实模式 x16专属
stConsole:
    ret
.clear:  ;void
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h
    ret
.resetCursor:    ;void
    mov ah, 02h  ; 设置光标位置
    mov bh, 0    ; 页码 0
    mov dx, 0    ; 行号 0, 列号 0
    int 10h
    ret
.showText:   ;ax字符串地址 cx字符串长度
    mov bp, ax  ; 将字符串地址传给 bp
    mov ax, 01301h  ; 设置为写字符到光标位置
    mov bx, 15  ; 页码 0, 颜色属性 15 (白色文本，黑色背景)
    int 0x10
    ret
stLogConsole:
    ret
.info:   ;ax字符串地址 cx字符串长度 dh行
    mov bp, ax  ; 将字符串地址传给 bp
    ; 设置行号和列号
    mov ah, 02h  ; 设置光标位置
    mov bh, 0    ; 页码 0
    mov dl, 0    ; 列号 0
    int 0x10
    ; 显示 [ INFO ]，绿色文本，黑色背景
    mov ax,0e20h
    mov     al, ' '
    int     0x10
    mov     al, '['
    int     0x10
    mov     al, ' '
    int     0x10
    mov     al, 'I'
    int     0x10
    mov     al, 'N'
    int     0x10
    mov     al, 'F'
    int     0x10
    mov     al, 'O'
    int     0x10
    mov     al, ' '
    int     0x10
    mov     al, ']'
    int     0x10
    mov     al, ' '
    int     0x10
    ; 显示信息内容，白色文本，黑色背景
    mov ah, 13h  ; 写字符串到光标位置
    mov al, 1    ; 写模式1，移动光标
    mov bh, 0    ; 页码 0
    mov bl, 02h  ; 设置颜色属性为绿色文本，黑色背景
    mov dl, 10    ; 列号 9
    int 0x10
    ret
.error:   ;ax字符串地址 cx字符串长度 dh行
    mov bp, ax  ; 将字符串地址传给 bp

    ; 设置行号和列号
    mov ah, 02h  ; 设置光标位置
    mov bh, 0    ; 页码 0
    mov dl, 0    ; 列号 0
    int 0x10

    ; 显示 [ ERROR ]，红色文本，黑色背景
    mov ax,0e20h
    mov     al, '['
    int     0x10
    mov     al, ' '
    int     0x10
    mov     al, 'E'
    int     0x10
    mov     al, 'R'
    int     0x10
    mov     al, 'R'
    int     0x10
    mov     al, 'O'
    int     0x10
    mov     al, 'R'
    int     0x10
    mov     al, ' '
    int     0x10
    mov     al, ']'
    int     0x10
    mov     al, ' '
    int     0x10

    ; 显示信息内容，白色文本，黑色背景
    mov ah, 13h  ; 写字符串到光标位置
    mov al, 1    ; 写模式1，移动光标
    mov bh, 0    ; 页码 0
    mov bl, 04h  ; 设置颜色属性为红色文本，黑色背景
    mov dl, 10    ; 列号 10（确保不会与 [ ERROR ] 重叠）
    int 0x10

    ret

init:
    mov ax, cs
    mov es, ax
    ret

KillMotor:
    push	dx
	mov	dx, 03F2h
	mov	al, 0
	out	dx, al
	pop	dx
	ret
[SECTION .s32]

ALIGN	32

[BITS	32]
x86Start:
    mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'K'
	mov	[gs:((80 * 1 + 39) * 2)], ax	; 屏幕第 1 行, 第 39 列。
	jmp	$