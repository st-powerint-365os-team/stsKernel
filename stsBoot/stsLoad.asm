;over512stsLoadBooting (c) 2025 sungbly_tsstt
;At stsBoot 
org 0xc200
jmp _start

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
    call while
while:
    hlt
    jmp while
stsLoadMessage:
    db "stsLoad Booting...", 0
stsProtectModeLoadingMsg:
    db "Loading protect Mode", 0
stsProtectedModeMsg:
; consoleLib
