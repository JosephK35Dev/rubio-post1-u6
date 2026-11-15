; lab6_modos.asm — demostración de modos de direccionamiento x86 de 16 bits
; Ensamble DOSBox: NASM -f bin SRC\LAB6_MODOS.ASM -o BIN\LAB6_MODOS.COM

BITS 16
ORG 100h

    jmp inicio

; Datos contiguos para inspeccionar con DEBUG y NASM -l.
array       dw 10, 20, 30, 40, 50
nota1       dw 85
nota2       dw 73
promedio    dw 0
var_x       dw 0FFFFh
matriz      dw 1, 2, 3
            dw 4, 5, 6
            dw 7, 8, 9

inicio:
; MODO 1 — inmediato: la constante está dentro de la instrucción.
modo_inmediato:
    mov ax, 100               ; inmediato decimal (0064h)
    mov bx, 0A5h
    xor cx, cx
    add cx, 55
    mov dx, 0FFFFh
    and dx, 00FFh

; MODO 2 — directo: la instrucción contiene el desplazamiento fijo.
modo_directo:
    mov ax, [var_x]           ; AX=FFFFh
    mov bx, [array]           ; BX=10
    mov cx, [nota1]           ; CX=85
    mov word [var_x], 0       ; forma NASM válida: tamaño antes del operando

; MODO 3 — indirecto por registro: SI contiene el desplazamiento.
modo_indirecto:
    mov si, nota1             ; SI = dirección de nota1
    mov ax, [si]              ; AX = 85
    mov si, nota2
    mov bx, [si]              ; BX = 73
    add ax, bx                ; 158
    shr ax, 1                 ; promedio entero = 79
    mov si, promedio
    mov [si], ax              ; almacenar el promedio mediante puntero
fin_indirecto:

; MODO 4 — indexado: dirección efectiva = BX + SI.
modo_indexado:
    mov bx, array
    mov si, 4                 ; 2.º índice (array[2]) × 2 bytes
    mov ax, [bx + si]         ; AX=30

; Recorrido en orden directo: AX=150 decimal (0096h).
bucle_array:
    xor ax, ax
    mov bx, array
    mov cx, 5
    xor si, si
.suma:
    add ax, [bx + si]
    add si, 2
    loop .suma
fin_bucle_array:

; Extensión: el mismo array, recorrido inverso, también suma 150.
bucle_inverso:
    xor ax, ax
    mov bx, array
    mov si, 8                 ; último word: 4 × 2 bytes
    mov cx, 5
.suma_inversa:
    add ax, [bx + si]
    sub si, 2
    loop .suma_inversa
fin_bucle_inverso:

; Tres campos contiguos: base de nota1 más desplazamientos 0,2,4.
campos_registro:
    mov bx, nota1
    mov ax, [bx]              ; nota1=85
    mov cx, [bx + 2]          ; nota2=73
    mov dx, [bx + 4]          ; promedio=79

; MODO 3b — BP accede por defecto al segmento SS; se reservan dos locales.
marco_bp:
    push bp
    mov bp, sp
    sub sp, 4                 ; dos palabras locales
    mov word [bp - 2], 99     ; local_1 (63 00)
    mov word [bp - 4], 250    ; local_2 (FA 00)
    mov ax, [bp - 2]
    add ax, [bp - 4]           ; AX=349 (015Dh)
fin_suma_bp:
    mov sp, bp
    pop bp
fin_marco_bp:

; Matriz 3x3 de words: matriz[1][2] = 6.
acceso_matriz:
    mov ax, 1                 ; fila
    mov bx, 3                 ; columnas por fila
    mul bx                    ; AX = fila × columnas = 3
    shl ax, 1                 ; desplazamiento de fila en bytes = 6
    mov si, ax
    mov cx, 2                 ; columna
    shl cx, 1                 ; desplazamiento de columna en bytes = 4
    add si, cx                ; SI = 10 (000Ah)
    mov bx, matriz
carga_matriz:
    mov dx, [bx + si]         ; DX=6
fin_matriz:
    int 20h
