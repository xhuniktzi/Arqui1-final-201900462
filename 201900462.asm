printMsg macro str
             mov ax, @data         ; ax = offset de la cadena
             mov ds, ax            ; ds = segmento de la cadena
             mov ah, 09h           ; imprimir cadena
             mov dx, offset str    ; dx = offset de la cadena
             int 21h               ; imprimir cadena
endm
printAsciiFromNum macro num
                      mov ax, @data    ; ax = offset de la cadena
                      mov ds, ax       ; ds = segmento de la cadena
                      mov ah, 02h      ; imprimir caracter
                      mov dl, num      ; dx = offset de la cadena
                      add dl, '0'
                      int 21h          ; imprimir cadena
endm

convertAsciiToNum macro ascii
                      mov dl, ascii
                      sub dl, '0'
endm

printAscii macro ascii
               mov ax, @data    ; ax = offset de la cadena
               mov ds, ax       ; ds = segmento de la cadena
               mov ah, 02h      ; imprimir caracter
               mov dl, ascii    ; dx = offset de la cadena
               int 21h          ; imprimir cadena
endm


saveCoef macro coef
             call readNum
             call saveNumToBuffer
             mov  ah, tempNum
             mov  coef, ah
endm

printCoefDiffWord macro coef
                      mov  ax, coef
                      mov  revertingNumDiff, ax
                      call writeNumToBufferDiff
                      call printNumFromBufferDiff
endm

.model small
.stack 100h
.data
    ; Mensajes
    msg1             db "Examen Final - VD2022 - Xhunik Miguel - 201900462", 13, 10, '$'
    msgnum           db "Ingrese dos numeros: ",13,10, '$'

    num1msg          db "NUM 1: ", '$'
    num2msg          db "NUM 2: ", '$'

    resultMsg        db "Resultado: ", '$'

    error            db "Error: Solo se permiten numeros", 13, 10, '$'

    num1             db 0                                                                   ; Numero 1
    num2             db 0                                                                   ; Numero 2

    result           dw 0                                                                   ; Resultado de la operacion

    ; Variables para la lectura de numeros
    tempNum          db 0
    signo            db 0
    bufferNum1       db 0
    bufferNum2       db 0

    
    ; Variables temporales writeNumDiff - 3 digitos
    
    bufferNum1Diff   db 0
    bufferNum2Diff   db 0
    bufferNum3Diff   db 0
    bufferNum4Diff   db 0

    
    ; Variable temporal revertNumDiff
    revertingNumDiff dw 0

    ; num temp binary
    number           dw 0
    ; maske            dw 0

.code


readNum proc
                              mov               signo, 0
                 
                              mov               bufferNum1, 0
                              mov               bufferNum2, 0

                              mov               ah, 07h
                              int               21h
                              cmp               al, '-'                      ; Si es negativo
                              je                readNumNeg

                              cmp               al, '0'
                              jb                readNumErr
                              cmp               al, '9'
                              ja                readNumErr
                              jmp               readNumFirst

    readNumProc:              
                              mov               ah, 07h
                              int               21h
     
                              cmp               al, '0'
                              jb                readNumErr
                              cmp               al, '9'
                              ja                readNumErr
    readNumFirst:             
                              convertAsciiToNum al
                              mov               bufferNum1, dl
                              printAsciiFromNum bufferNum1

                              mov               ah, 07h
                              int               21h
                 
                              cmp               al, '0'
                              jb                readNumErr
                              cmp               al, '9'
                              ja                readNumErr
                              convertAsciiToNum al
                              mov               bufferNum2, dl
                              printAsciiFromNum bufferNum2
                  
                              jmp               readNumEnd
    readNumNeg:               
                              printAscii        '-'
                              mov               signo, 1
                              jmp               readNumProc
    readNumErr:               
                              printMsg          error
                 
    readNumEnd:               
                              printAscii        13
                              printAscii        10
                              ret

readNum endp

saveNumToBuffer proc
                              mov               tempNum, 0
                           
                              mov               al, 10
                              mul               bufferNum1
                              add               al, bufferNum2
                              mov               tempNum, al
                              cmp               signo, 1
                              je                saveNumToBufferNeg
                              ret
    saveNumToBufferNeg:       
                              neg               tempNum
                              ret

saveNumToBuffer endp



writeNumToBufferDiff proc
                              mov               bufferNum1Diff,0
                              mov               bufferNum2Diff,0
                              mov               bufferNum3Diff,0
                              mov               signo,0

    ; check if number is negative
                              cmp               revertingNumDiff, 0
                              jl                writeNumToBufferDiffNeg
                              cmp               revertingNumDiff, 0
                              jge               writeNumToBufferDiffPos
    writeNumToBufferDiffNeg:  
                              neg               revertingNumDiff
                              mov               signo, 1
    writeNumToBufferDiffPos:  
                              mov               dx, 0
                              mov               ax,0
                              mov               ax, revertingNumDiff
                              mov               bx, 1000
                              div               bx
                              mov               bufferNum1Diff, al


                              mov               ax, dx
                              mov               dx, 0
                              mov               bx, 100
                              div               bx
                              mov               bufferNum2Diff, al


    ;   mov               bufferNum3Diff, dl

                              mov               ax, dx
                              mov               dx, 0
                              mov               bx, 10
                              div               bx
                              mov               bufferNum3Diff, al
                              mov               bufferNum4Diff, dl

                              ret
writeNumToBufferDiff endp


printNumFromBufferDiff proc
                              cmp               signo, 1
                              je                printNumFromBufferDiffNeg
                              printAscii        '+'
                              printAsciiFromNum bufferNum1Diff
                              printAsciiFromNum bufferNum2Diff
                              printAsciiFromNum bufferNum3Diff
                              printAsciiFromNum bufferNum4Diff
                              ret
    printNumFromBufferDiffNeg:
                              printAscii        '-'
                              printAsciiFromNum bufferNum1Diff
                              printAsciiFromNum bufferNum2Diff
                              printAsciiFromNum bufferNum3Diff
                              printAsciiFromNum bufferNum4Diff
                              ret
printNumFromBufferDiff endp

    ; ax, bx = numeros a multiplicar
    ; ax = resultado
mulAddCalculate proc

    multiply:                 
    ;   push              bx                           ; guarda el valor de bx para usarlo más tarde
                              mov               cx, ax                       ; cx se usará como contador
                              xor               ax, ax                       ; inicializa el resultado en 0

    
                              cmp               cx, 0
                              jl                negative
                              jmp               add_loop
    negative:                 
                              neg               cx
                              neg               bx
    
    add_loop:                 
                              add               ax, bx
                              loop              add_loop

    ; si cx era negativo, invertir ax
                              cmp               cx, 0
                              jge               done
                              neg               ax
    done:                     
    ;   pop               bx
                              ret
mulAddCalculate endp

printBin proc

                              mov               cx, 16
                              mov               bx, number
 
    printBinLoop:             
                              shl               bx, 1
                              jc                printBinOne
                              jmp               printBinZero
    printBinOne:              
                              printAscii        '1'
                              jmp               printBinNext
    printBinZero:             
                              printAscii        '0'
    printBinNext:             
                              loop              printBinLoop
                              printAscii        13
                              printAscii        10
                              ret
printBin endp

printHexa proc

                              mov               cx, 0

    printHexaLoop:            
                              cmp               ax, 0
                              je                printHexaExit

                              xor               dx, dx
                              mov               bx, 16
                              div               bx

                              cmp               dx, 9
                              jle               printHexaA

                              cmp               dx, 9
                              jg                printHexaB

    printHexaA:               
                              add               dx, 48
                              jmp               printHexaC
    printHexaB:               
                              add               dx, 55
    printHexaC:               
                              push              dx
                              inc               cx

                              jmp               printHexaLoop
    printHexaExit:            

                              pop               dx
                              printAscii        dl
                              loop              printHexaExit
                              ret
printHexa endp

main proc

    mnloop:                   
                              mov               ax, @data
                              mov               ds, ax

                              printMsg          msg1
                              printMsg          msgnum

                              printMsg          num1msg
                              saveCoef          num1

                              printMsg          num2msg
                              saveCoef          num2

                              printMsg          resultMsg
                              
                              cmp               num1, 0
                              mov               ax, 0
                              jge               mainPos1
                              not               ah
    mainPos1:                 
                              mov               al, num1

                              cmp               num2, 0
                              mov               bx, 0
                              jge               mainPos2
                              not               bh
    mainPos2:                 
                              mov               bl, num2
                              call              mulAddCalculate
                              
                              mov               result, ax
                              mov               number, ax
    

                              printCoefDiffWord result
                              printAscii        13
                              printAscii        10

                              call              printBin

                              printAscii        13
                              printAscii        10

                              mov               ax, result
                              call              printHexa

                              printAscii        13
                              printAscii        10

                              jmp               mnloop
main endp
    end main