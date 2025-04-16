@REM 直接在MAKEFILE里搞会报错
type stsBoot\stsLoad.asm lib\stConsole.asm > temp\stsLoad.asm
compile_tools\nasm-2.16rc12\nasm.exe temp\stsLoad.asm -o bin\stsLoad.bin