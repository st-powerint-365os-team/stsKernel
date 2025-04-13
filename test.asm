org 0xc200
jmp load
load:
    call clear        ; 清屏
    call resetCursor  ; 重置光标位置
    mov ax, successMsg
    mov cx, 27
    call showText     ; 显示加载成功消息
    jmp while
while:
    hlt
    jmp $
clear:
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h
    ret
resetCursor:
    mov ah, 02h  ; 设置光标位置
    mov bh, 0    ; 页码 0
    mov dx, 0    ; 行号 0, 列号 0
    int 10h
    ret
showText:
    mov bp, ax  ; 将字符串地址传给 bp
    mov ax, 01301h  ; 设置为写字符到光标位置
    mov bx, 15  ; 页码 0, 颜色属性 15 (白色文本，黑色背景)
    mov dl, 0  ; 列号 0
    int 0x10
    ret
successMsg:
    db "stsBoot loaded successfully", 0
