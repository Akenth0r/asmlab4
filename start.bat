nasm -f win32 %1 -o test.obj -l test.lst
golink /console test.obj kernel32.dll
test.exe
