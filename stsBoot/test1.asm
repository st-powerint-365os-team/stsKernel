org 0xc200
jmp load
load:
    mov ah,0
    mov al,01
    int 0x10