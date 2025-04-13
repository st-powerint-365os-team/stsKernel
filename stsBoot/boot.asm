org 07c00h

CYLS    equ     10
jmp entry

entry:
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00
    mov ds, ax

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
    mov dl, 0           ; 列号 0
    int 0x10
    ret

Msg:
    db "2025 stsBoot Loading...", 0

while:
    hlt
    jmp while

read:
    MOV     AX, 0            ; 初始化寄存器
    MOV     SS, AX
    MOV     SP, 0x7c00
    MOV     DS, AX

    MOV     AX, 0x0820
    MOV     ES, AX
    MOV     CH, 0            ; 柱面0
    MOV     DH, 0            ; 磁头0
    MOV     CL, 2            ; 扇区2

readloop:
    CALL    checkKeyPress      ; 检查按键输入
    CMP     AL, 0x20         ; 检查是否按下了空格键
    JNE     .continue_reading

    CALL    clear            ; 清屏
    call    resetCursor      ; 重置光标位置
    INC     cx               ; 增加页码
    JMP     readloop

.continue_reading:
    MOV     SI, 0            ; 记录失败次数寄存器

retry:
    ; 调试信息：显示当前读取的柱面号、磁头号和扇区号（十六进制形式）
    MOV     AX, 0x0E20       ; 设置为写字符到光标位置（TELETYPE模式）

    ; 显示 CH (柱面号)
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

    ; 换行显示
    mov     al, 0x0A
    int     0x10
    mov     al, 0x0D
    int     0x10

    MOV     AH, 0x02         ; AH=0x02 : 读入磁盘
    MOV     AL, 1            ; 1个扇区
    MOV     BX, 0
    MOV     DL, 0x00         ; A驱动器
    INT     0x13             ; 调用磁盘BIOS

    JNC     next             ; 没出错则跳转到next
    ADD     SI, 1            ; 往SI加1
    CMP     SI, 5            ; 比较SI与5
    JAE     error            ; SI >= 5 跳转到error
    MOV     AH, 0x00
    MOV     DL, 0x00         ; A驱动器
    INT     0x13             ; 重置驱动器
    JMP     retry
next:
    MOV     AX, ES           ; 把内存地址后移0x200（512字节）
    ADD     AX, 0x0020
    MOV     ES, AX
    ADD     CL, 1            ; 往CL里面加1
    CMP     CL, 18           ; 比较CL与18
    JBE     readloop         ; CL <= 18 跳转到readloop
    MOV     CL, 1
    ADD     DH, 1
    CMP     DH, 2
    JB      readloop         ; DH < 2 跳转到readloop
    MOV     DH, 0
    ADD     CH, 1
    CMP     CH, CYLS
    JB      readloop         ; CH < CYLS 跳转到readloop

    ; 磁盘读取成功，跳转到加载代码
    ; JMP     0xc200

error:
    ; 清屏并重置光标位置
    CALL    clear
    CALL    resetCursor

    ; 显示错误消息
    mov ax,cs
    mov ds,ax
mov es,ax
    mov ax, errorMsg
    mov cx, 33
    call showTextCustom       ; 显示错误消息

    ; 显示错误码（十六进制形式）
    MOV     AX, 0x0E20       ; 设置为写字符到光标位置（TELETYPE模式）
    MOV     AL, AH           ; 显示错误码
    CALL    printHexByte     ; 打印十六进制字节

    jmp while

errorMsg:
    db "Error loading stsBoot Error code: ", 0

clear:
    mov ax, 0600h         ; 清屏
    mov bx, 0700h         ; 背景颜色
    mov cx, 0             ; 从行 0 开始
    mov dx, 184fh         ; 到达行 24 结束
    int 10h
    ret

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
    INT     0x10
    RET
showTextCustom:
    mov bp, ax  ; 将字符串地址传给 bp
    mov ax, 01301h  ; 设置为写字符到光标位置
    mov bx, 15  ; 页码 0, 颜色属性 15 (白色文本，黑色背景)
    int 0x10
    ret
checkKeyPress:
    ; 检查是否有按键输入
    mov ah, 01h              ; 检查按键缓冲区
    int 0x16                 ; 调用键盘BIOS
    jz .no_key               ; 如果没有按键，跳转到.no_key

    mov ah, 00h              ; 读取按键输入
    int 0x16                 ; 调用键盘BIOS
    ret
.no_key:
    xor ax, ax
    ret
end:
    times 510 - ($ - $$) db 0
    dw 0xaa55              ; 引导签名