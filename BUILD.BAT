@echo off
nasm -f bin lab6ins.asm -o lab6ins.com -l lab6ins.lst
nasm -f bin lab6mod.asm -o lab6mod.com -l lab6mod.lst
nasm -f bin lab6fac.asm -o lab6fac.com -l lab6fac.lst
dir lab6*.com
