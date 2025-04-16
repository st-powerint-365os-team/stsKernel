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
    mov dl, 9    ; 列号 9
    int 0x10
    ret
.error:   ;ax字符串地址 cx字符串长度 dh行
    mov bp, ax  ; 将字符串地址传给 bp

    ; 设置行号和列号
    mov ah, 02h  ; 设置光标位置
    mov bh, 0    ; 页码 0
    mov dl, 0    ; 列号 0
    int 0x10

    ; 调试输出：显示一个字符
    mov ah, 0eh
    mov al, 'S'
    int 10h

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
    mov dl, 10    ; 列号 12（确保不会与 [ ERROR ] 重叠）
    int 0x10

    ret

init:
    mov ax, cs
    mov es, ax
info_TEXT:
    db '[ INFO ] ', 0