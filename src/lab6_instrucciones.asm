; lab6_instrucciones.asm — categorías de instrucciones x86 de 16 bits
; Ensamble DOSBox: NASM -f bin SRC\LAB6_INSTRUCCIONES.ASM -o BIN\LAB6_INSTRUCCIONES.COM
; Formato COM: CS, DS, ES y SS comparten el segmento; entrada en 0100h.

BITS 16
ORG 100h

    jmp inicio                 ; saltar sobre los datos

valor_a   dw 45
valor_b   dw 12
resultado dw 0
mascara   db 0Fh

inicio:
; BLOQUE 1 — transferencia de datos
    mov ax, [valor_a]          ; AX = 45
    mov bx, [valor_b]          ; BX = 12
    mov cx, ax                 ; copia entre registros
    mov dx, bx
    lea si, [valor_a]           ; SI recibe la dirección, no el contenido
    mov ax, [si]               ; direccionamiento indirecto: AX = 45
    xchg cx, dx                ; intercambio temporal
    xchg cx, dx                ; restaurar CX=45, DX=12
    push ax                    ; preservar AX
    mov ax, 0FFFFh
    pop ax                     ; recuperar AX=45

; BLOQUE 2 — aritmética y observación de flags
    mov ax, [valor_a]
prueba_add:
    add ax, [valor_b]          ; AX = 57; ZF=0, CF=0, OF=0
    mov [resultado], ax

    mov ax, [valor_b]
prueba_sub:
    sub ax, [valor_a]          ; AX = FFDFh (-33 con signo)

    mov ax, [valor_a]
    inc ax                     ; 46
    dec ax                     ; 45

    mov al, 10
    mov bl, 7
    mul bl                     ; AX = AL*BL = 70 (AH:AL; DX no es el resultado)

    mov ax, 100
    mov bl, 7
    div bl                     ; AL = cociente 14; AH = resto 2

; BLOQUE 3 — lógica, pruebas de bits y desplazamientos
    mov al, 0B7h
prueba_and:
    and al, [mascara]          ; AL=07h: conserva los cuatro bits bajos

    mov al, 0B7h
    or al, 0F0h                ; AL=F7h: activa los cuatro bits altos

    mov al, 0AAh
    xor al, 0FFh               ; AL=55h: inversión de los bits
    xor bx, bx                 ; BX=0

    mov al, 0B7h
prueba_test:
    test al, 01h               ; AL no cambia; ZF=0 porque bit 0 está activo

    mov al, 08h
    shl al, 2                  ; AL=20h (8 × 4)
    shr al, 1                  ; AL=10h (32 / 2)

; BLOQUE 4 — decisión condicional y bucle contado
bloque_control:
    mov ax, [valor_a]
prueba_cmp:
    cmp ax, [valor_b]          ; 45 > 12: JG toma el salto
    jg .mayor
    je .igual
    xor cx, cx                 ; caso menor
    jmp .fin_comparacion
.mayor:
    mov cx, 1
    jmp .fin_comparacion
.igual:
    mov cx, 2
.fin_comparacion:

bucle_suma:
    xor ax, ax                 ; acumulador = 0
    mov cx, 5
    mov bx, 1
.iteracion:
    add ax, bx                 ; AX = 1+2+3+4+5 = 15
    inc bx
    loop .iteracion
fin_bucle_suma:

; BLOQUE 5 — SHL/SHR descartan; ROL/ROR reinsertan el bit que sale
bloque_rotacion:
    mov al, 81h                ; 10000001b
    mov bl, al
    shl bl, 1                  ; BL=02h, CF=1; bit 7 sale del byte
    mov cl, al
    rol cl, 1                  ; CL=03h, CF=1; bit 7 pasa al bit 0
    mov dl, al
    shr dl, 1                  ; DL=40h, CF=1; bit 0 se descarta del byte
    mov bh, al
    ror bh, 1                  ; BH=C0h, CF=1; bit 0 pasa al bit 7

    mov al, 0A5h
    rol al, 4                  ; AL=5Ah: intercambia los dos nibbles
fin_rotacion:
    int 20h
