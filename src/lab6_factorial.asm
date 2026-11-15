; Variante educativa del bucle contado: calcula 5! = 120.
; Compilación en DOSBox: NASM -f bin DOS\LAB6FAC.ASM -o DOS\LAB6FAC.COM
BITS 16
ORG 100h

inicio:
    mov ax, 1             ; acumulador del producto
    mov bx, 1             ; multiplicador inicial
    mov cx, 5             ; cinco factores: 1, 2, 3, 4 y 5
.factor:
    mul bx                ; DX:AX = AX * BX; el resultado final cabe en AX
    inc bx
    loop .factor
    int 20h
