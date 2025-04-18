@REM 直接在MAKEFILE里搞会报错
type stsBoot\stsLoad.asm lib\s16stConsole.asm lib\HardwareLib.asm stsBoot\stsx86Load.asm > temp\stsLoad.asm
compile_tools\nasm-2.16rc12\nasm.exe temp\stsLoad.asm -o bin\stsLoad.bin