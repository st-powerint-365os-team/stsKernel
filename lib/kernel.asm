
init:
    mov ax, cs
    mov ds, ax
    mov es, ax
    ret
print:
    mov bp, ax  ; 将字符串地址传给 bp
    call init
    mov ax, 01301h  ; 设置为写字符到光标位置
    mov bx, 15  ; 页码 0, 颜色属性 15 (白色文本，黑色背景)
    mov dl, 0  ; 列号 0
    int 0x10
    ret
