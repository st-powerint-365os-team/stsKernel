org 07c00h;核心使用30day floppy bootloader

CYLS    equ     10
jmp entry
nop
; 下面是 FAT12 磁盘的头
	BS_OEMName	DB 'STKENREL'	; OEM String, 必须 8 个字节
	BPB_BytsPerSec	DW 512		; 每扇区字节数
	BPB_SecPerClus	DB 1		; 每簇多少扇区
	BPB_RsvdSecCnt	DW 1		; Boot 记录占用多少扇区
	BPB_NumFATs	DB 2		; 共有多少 FAT 表
	BPB_RootEntCnt	DW 224		; 根目录文件数最大值
	BPB_TotSec16	DW 2880		; 逻辑扇区总数
	BPB_Media	DB 0xF0		; 媒体描述符
	BPB_FATSz16	DW 9		; 每FAT扇区数
	BPB_SecPerTrk	DW 18		; 每磁道扇区数
	BPB_NumHeads	DW 2		; 磁头数(面数)
	BPB_HiddSec	DD 0		; 隐藏扇区数
	BPB_TotSec32	DD 0		; wTotalSectorCount为0时这个值记录扇区数
	BS_DrvNum	DB 0		; 中断 13 的驱动器号
	BS_Reserved1	DB 0		; 未使用
	BS_BootSig	DB 29h		; 扩展引导标记 (29h)
	BS_VolID	DD 0		; 卷序列号
	BS_VolLab	DB 'STSKENREL01'; 卷标, 必须 11 个字节
	BS_FileSysType	DB 'FAT12   '	; 文件系统类型, 必须 8个字节  
RESB	18	
entry:
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00
    mov ds, ax
    mov ah,0
    mov al,41h
    int 10h
    mov ax, Msg
    mov cx, 23
    call showText     ; 显示 "2025 stsBoot Loading..."

    ; 初始化调试信息行号
    mov bx, 0           ; 变量用于跟踪当前行数
    mov si, 0           ; 重置失败次数
    jmp read

showText:
    mov bp, ax          ; 将字符串地址传给 bp
    mov ax, 01301h      ; 设置为写字符到光标位置
    mov bx, 15          ; 页码 0, 颜色属性 15 (白色文本，黑色背景)
    int 0x10
    ret

resetCursor:
    mov ah, 02h         ; 设置光标位置
    mov bh, 0           ; 页码 0
    mov dx, 0           ; 行号 0, 列号 0
    int 0x10
    ret

setCursorBottom:
    mov ah, 02h         ; 设置光标位置
    mov bh, 0           ; 页码 0
    mov dh, 24          ; 行号 24 (屏幕底部)
    mov dl, 42          ; 列号 0
    int 0x10
    ret

Msg:
    db "2025 stsBoot Loading...", 0

while:
    hlt
    jmp while

read:
    	MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 读取磁盘

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2

readloop:
    MOV     SI, 0            ; 记录失败次数寄存器

retry:
    ; 调试信息：显示当前读取的柱面号、磁头号和扇区号（十六进制形式）
    MOV     AX, 0x0E20       ; 设置为写字符到光标位置（TELETYPE模式）

    mov     al, '['
    int     0x10
    mov     al, ' '
    ; 显示 CH (柱面号)
    mov     al, ' '
    int     0x10
    mov     al, 'C'
    int     0x10
    mov     al, 'H'
    int     0x10
    mov     al, ':'
    int     0x10
    MOV     AL, CH           ; 显示柱面号
    CALL    printHexByte     ; 打印十六进制字节

    ; 显示 DH (磁头号)
    mov     al, ' '
    int     0x10
    mov     al, 'D'
    int     0x10
    mov     al, 'H'
    int     0x10
    mov     al, ':'
    int     0x10
    MOV     AL, DH           ; 显示磁头号
    CALL    printHexByte     ; 打印十六进制字节

    ; 显示 CL (扇区号)
    mov     al, ' '
    int     0x10
    mov     al, 'C'
    int     0x10
    mov     al, 'L'
    int     0x10
    mov     al, ':'
    int     0x10
    MOV     AL, CL           ; 显示扇区号
    CALL    printHexByte     ; 打印十六进制字节

    ; 调试信息：显示读取状态
    mov     al, ' '
    int     0x10
    mov     al, ']'
    int     0x10

    	MOV		AH,0x02			; AH=0x02 : 读入磁盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		next			; 没出错则跳转到fin
		ADD		SI,1			; 往SI加1
		CMP		SI,5			; 比较SI与5
		JAE		error			; SI >= 5 跳转到error
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JMP		retry


.success:
    mov     al, 'O'
    int     0x10
    mov     al, 'K'
    int     0x10

    ; 不换行显示下一个读取信息
    jmp     next

success:
    mov ax, cs
    mov ds, ax
    mov es, ax
    ; mov ax, successMsg
    ; mov cx, 27
    ; call showText     ; 显示加载成功消息
    MOV		[0x0ff0],CH	
    JMP		0xc200
; successMsg:
;     db "stsBoot loaded successfully", 0
clear:
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h
    ret
next:
        MOV		AX,ES			; 把内存地址后移0x200（512/16十六进制转换）
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES,0x020因为没有ADD ES，只能通过AX进行
		ADD		CL,1			; 往CL里面加1
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; CL <= 18 跳转到readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; DH < 2 跳转到readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS 跳转到readloop


    ; 磁盘读取成功，跳转到加载代码
    call success

error:
    ; 设置光标到屏幕底部
    CALL    setCursorBottom

    ; 显示错误消息
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, errorMsg
    mov cx, 33               ; 调整 cx 以匹配字符串长度
    call showText            ; 显示错误消息

    ; 显示错误码（十六进制形式，黄色显示）
    MOV     AL, AH           ; 获取错误码
    CALL    printHexByte     ; 打印十六进制字节

    jmp while

errorMsg:
    db "Error loading stsBoot Error code: ", 0

printHexByte:
    ; 打印十六进制字节
    MOV     AH, 0x0E       ; 设置为写字符到光标位置（TELETYPE模式）
    MOV     BL, AL           ; 保存AL到BL
    SHR     AL, 4            ; 提取高4位
    CALL    printHexNibble   ; 打印高4位
    MOV     AL, BL           ; 恢复AL
    AND     AL, 0x0F         ; 提取低4位
    CALL    printHexNibble   ; 打印低4位
    RET

printHexNibble:
    ; 打印十六进制半字节
    CMP     AL, 0x09         ; 比较AL与9
    JBE     .low_digit       ; 如果AL <= 9, 跳转到.low_digit
    ADD     AL, 7            ; 如果AL > 9, 调整为字母A-F

.low_digit:
    ADD     AL, 0x30         ; 转换为ASCII字符
    MOV     BX, 0x0E        ; 颜色属性 0E (黄色文本，黑色背景)
    INT     0x10
    RET

end:
    times 510 - ($ - $$) db 0
    dw 0xaa55              ; 引导签名