# Post 1 — Unidad 6: Instrucciones y direccionamiento

**Estudiante:** Rubio  
**Curso:** Arquitectura de Computadores  
**Entorno observado:** DOSBox 0.74-3, NASM 2.16.03 y DEBUG.COM disponible en la carpeta de trabajo.

El repositorio documenta las dos partes del laboratorio. Los programas fuente se encuentran en `src/`, los ejecutables y listados de NASM en `bin/`, y las capturas reales de DOSBox en `capturas/`. Las copias `LAB6INS.ASM`, `LAB6MOD.ASM` y `LAB6FAC.ASM` conservan nombres DOS 8.3 para que NASM pueda abrirlas desde DOSBox; cada una corresponde al archivo fuente del mismo nombre lógico en `src/`. `BUILD.BAT` compila las tres copias. Los ejecutables `.COM` entregados en `bin/` se compilaron con NASM y se recorrieron con el DEBUG disponible en el entorno.

## Parte 1 — Programa de instrucciones mixtas

El programa `src/lab6_instrucciones.asm` recorre transferencia de datos, aritmética, lógica, comparación y control de flujo. `bin/lab6_instrucciones.com` contiene el resultado compilado; `bin/lab6_instrucciones.lst` conserva la correspondencia de NASM entre direcciones, bytes e instrucciones.

### Bloques y resultados observados

| Bloque | Instrucciones principales | Resultado verificado |
|---|---|---|
| Transferencia | `MOV`, `LEA`, `XCHG`, `PUSH`, `POP` | Carga 45 y 12 en registros, copia direcciones/contenidos y restaura AX mediante la pila. La variable `valor_a` se encuentra en DS:0102. |
| Aritmética | `ADD`, `SUB`, `INC`, `DEC`, `MUL`, `DIV` | `45+12=57` (`AX=0039`); `12−45=FFDFh` (−33); `10×7=70` en AX; `100÷7` deja cociente 14 en AL y resto 2 en AH. |
| Lógica y bits | `AND`, `OR`, `XOR`, `TEST`, `SHL`, `SHR` | `B7h AND 0Fh=07h`; `B7h OR F0h=F7h`; `AAh XOR FFh=55h`; `TEST B7h,01h` conserva AL y detecta el bit activo. |
| Comparación y bucle | `CMP`, `JG`, `JE`, `LOOP` | La comparación 45 frente a 12 toma `JG`. El bucle suma 1+2+3+4+5 y DEBUG observa `AX=000F`, `CX=0000`. |
| Rotación | `SHL`, `SHR`, `ROL`, `ROR` | Con `81h`: SHL produce `02h`, ROL `03h`, SHR `40h` y ROR `C0h`; con `A5h`, `ROL AL,4` produce `5Ah`. |

### Flags observados con DEBUG

Los nombres de DEBUG describen el estado después de ejecutar cada instrucción. En el código se comparan estos valores con las banderas: `NV/V` = OF, `NC/CY` = CF, `NZ/ZR` = ZF, `PL/NG` = SF, `PO/PE` = PF.

| Instrucción | Resultado | Flags relevantes en la captura |
|---|---:|---|
| `ADD AX,[valor_b]` | `AX=0039` | `OF=0`, `CF=0`, `ZF=0`, `SF=0`. |
| `SUB AX,[valor_a]` | `AX=FFDF` | `OF=0`, `CF=1`, `ZF=0`, `SF=1`; el resultado es −33 en complemento a dos. |
| `AND AL,[mascara]` | `AL=07` | `ZF=0`, `CF=0`; el AND actualiza las banderas y deja solo los cuatro bits bajos. |
| `TEST AL,01` | `AL=B7` sin cambio | `ZF=0`; TEST calcula el AND para las banderas, sin escribir el resultado en AL. |
| `CMP AX,[valor_b]` | AX sigue en `002D` | Para 45>12, `ZF=0`, `CF=0`, `SF=0`, `OF=0`; por ello el salto `JG` se toma. |

Las capturas `p1_cp2a_flags_add_sub.png`, `p1_cp2b_flags_and_test.png` y `p1_cp2c_flags_cmp.png` muestran los pasos de DEBUG. `p1_cp3_bucle_suma_15.png` muestra el acumulador final del bucle.

### Variante del bucle: factorial de 5

`src/lab6_factorial.asm` conserva la estructura de contador con `LOOP`, pero sustituye la suma por multiplicación acumulada: 1×2×3×4×5. Como el resultado de 5! cabe en 16 bits, `MUL BX` deja `DX=0000` y `AX=0078` (120 decimal). La captura `p1_cp5_factorial_120.png` registra el resultado real obtenido al detener DEBUG antes de `INT 20h`.

### Decisión técnica 1 — Desplazamientos frente a rotaciones

Para una operación aritmética de multiplicación o división por una potencia de dos, el estudiante elegiría `SHL` o `SHR`, porque cada desplazamiento mueve los bits a la posición que corresponde al nuevo valor y el bit que sale del registro queda fuera del resultado. El bit expulsado puede consultarse en CF, pero no vuelve a formar parte del operando. En cambio, si la tarea exige conservar todos los bits de un campo circular —por ejemplo, recorrer una máscara, una secuencia de bits o intercambiar los dos nibbles de un byte—, el estudiante preferiría `ROL` o `ROR`: el bit que sale se reinserta por el extremo opuesto. El laboratorio lo ilustra con `81h`: `SHL` da `02h`, mientras `ROL` da `03h`; de modo equivalente, `SHR` da `40h` y `ROR` da `C0h`. El ejemplo `ROL AL,4` transforma `A5h` en `5Ah` sin perder información. Esta elección se basa en el significado de los datos, no solo en la instrucción más corta. Para un conteo de rotación mayor que uno no se debe inferir OF; el programa únicamente comprueba el resultado y CF observado.

### Decisión técnica 2 — LOOP frente a DEC/JNZ

Para un bucle cuyo contador está en CX, el estudiante mantendría `LOOP` cuando se priorizan una estructura compacta y una lectura directa del propósito: decrementa CX y repite mientras no llegue a cero, sin alterar las banderas aritméticas del cuerpo. En el programa, esa propiedad deja disponible el estado de `ADD` del acumulador hasta que otra instrucción lo cambie. `DEC CX` seguido de `JNZ etiqueta` expresa el mismo conteo de forma más explícita y permite modificar o inspeccionar el contador entre ambas operaciones, aunque `DEC` sí actualiza varias banderas y ocupa una instrucción adicional. La velocidad depende del procesador: para el 8086, el manual de Intel lista `LOOP` en 17 ciclos cuando salta y 5 cuando termina; `DEC reg16` más `JNZ` suma aproximadamente 18/6 ciclos con los tiempos de esa misma tabla. Esa diferencia pequeña no predice el rendimiento de procesadores x86 modernos. Si el objetivo es claridad del código de 16 bits del laboratorio, `LOOP` es adecuado; si se requiere controlar las banderas, ampliar el rango del salto o ajustar el bucle a otro procesador, conviene considerar `DEC/JNZ` y medir en el hardware previsto.

### Evidencia de la Parte 1

- Compilación de los tres programas: `capturas/p1_cp1_compilacion_tres_programas.png`.
- Registro y comparación: `capturas/p1_cp2a_flags_add_sub.png`, `capturas/p1_cp2b_flags_and_test.png`, `capturas/p1_cp2c_flags_cmp.png`.
- Multiplicación y división: `capturas/p1_cp2d_mul_div.png`.
- Resultado del bucle: `capturas/p1_cp3_bucle_suma_15.png`.
- Diferencia entre desplazamientos y rotaciones: `capturas/p1_cp4_rotaciones_parte1.png` y `capturas/p1_cp4_rotaciones_resultado_5a.png`.
- Variante factorial: `capturas/p1_cp5_factorial_120.png`.

## Fuentes técnicas

- Intel Corporation. (1979). *The 8086 family user's manual*. Las tablas 2-20 y 2-21 documentan los tiempos de cálculo de dirección efectiva y los ciclos de `LOOP`, saltos condicionales e instrucciones de registro. [Manual de Intel, PDF](https://bitsavers.org/components/intel/8086/9800722-03_The_8086_Family_Users_Manual_Oct79.pdf).
- NASM. (s. f.). *The Netwide Assembler documentation*. [Documentación oficial de NASM](https://www.nasm.us/doc/).


