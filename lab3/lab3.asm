STSEG SEGMENT PARA STACK "STACK"
          DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA "DATA"
    fromUserX   DW 0
    fromUserY   DW 0
    number      DW 0
    divRest     DW 0
    ; expected length, actual length, 7 times 0 for actual value as string
    inputValue  DB 7, ?, 7 DUP ( 0 )
    labelForX   DB "Enter X value in range [-32767; 32767]: $"
    labelForY   DB "Enter Y value in range [-32767; 32767]: $"
    newLine     DB 10, 13, "$"
    formatErr   DB "Incorrect format!$"
    overflowErr DB "Overflow error!$"
    tryAgain    DB "Try again: $"
    restLabel   DB " and rest $"
    isNegative  DB 0
DSEG ENDS

CSEG SEGMENT PARA "CODE"
MAIN PROC FAR
                        ASSUME CS:CSEG, DS:DSEG, SS:STSEG
    STARTMAIN:          
                        PUSH   DS
                        XOR    AX, AX
                        PUSH   AX
                        MOV    AX, DSEG
                        MOV    DS, AX
    ;----------------------------------------------
                        call   getX
                        call   getY
                        CMP    fromUserX, 0
                        JE     COMMONANS
                        JG     XPOS

                        CMP    fromUserY, 0
                        JG     COMMONANS
    ; second
                        MOV    AX, 25
                        IMUL   fromUserY
                        JO     OVERFOP
                        MOV    BX, AX
                        call   printNumber
                        JMP    ENDProg
    XPOS:               
                        CMP    fromUserY, 0
                        JL     COMMONANS
                        JG     YPOS

                        CMP    fromUserX, 10
                        JL     COMMONANS

    ; third
                        MOV    AX, 6
                        IMUL   fromUserX
                        JO     OVERFOP
                        MOV    BX, AX
                        call   printNumber
                        JMP    ENDProg

    ; first
    YPOS:               
                        MOV    BX, fromUserX
                        ADD    BX, fromUserY
                        JO     OVERFOP
                
                        MOV    AX, fromUserX
                        IMUL   fromUserY
                        JO     OVERFOP

                        XCHG   AX, BX

                        IDIV   BX
                        call   printNumberAfterDiv
                        JMP    ENDProg

    COMMONANS:          
    ; last
                        MOV    BX, 1
                        call   printNumber
                        JMP    ENDProg
    
    OVERFOP:            
                        LEA    DX, overflowErr
                        call   print
                        LEA    DX, newLine
                        call   print
                        JMP    STARTMAIN
    ENDProg:            
                        RET
MAIN ENDP

printNumberAfterDiv PROC
                        MOV    BX, AX
                        MOV    divRest, DX
                        call   printNumber
                        CMP    divRest, 0
                        JE     ENDPR
                        LEA    DX, restLabel
                        call   print
                        MOV    BX, divRest
                        call   printNumber
    ENDPR:              
                        RET
printNumberAfterDiv ENDP

getX PROC
                        LEA    DX, labelForX
                        call   print
                        CALL   inputNumber
                        MOV    fromUserX, AX
                        RET
getX ENDP

getY PROC
                        LEA    DX, labelForY
                        call   print
                        CALL   inputNumber
                        MOV    fromUserY, AX
                        RET
getY ENDP
    ; mov label to input into currentInput and call inputNumber
    ; return value in AX
inputNumber PROC
    INPSTART:           
                        LEA    DX, inputValue
                        MOV    AH, 10
                        INT    21H

                        LEA    DX, newLine
                        CALL   print

                        XOR    AX, AX
                        MOV    isNegative, 0

                        MOV    CL, inputValue + 1
                        MOV    SI, 2

                        CMP    inputValue + 2, '-'
                        JNE    ITER
                        INC    SI
                        DEC    CL
                        MOV    isNegative, 1
    ITER:               
                        MOV    BL, inputValue[SI]
                        CMP    BL, '0'
                        JL     INCORRECT
                        CMP    BL, '9'
                        JG     INCORRECT

                        SUB    BL, '0'

                        MOV    DX, 10
                        IMUL   DX
                        JO     OVERF
                        ADD    AX, BX
                        JO     OVERF
                        INC    SI
                        LOOP   ITER
                        CMP    isNegative, 0
                        JE     INPUTEND
                        NEG    AX
                        JMP    INPUTEND

    INCORRECT:          
                        LEA    DX, formatErr
                        CALL   Print
                        LEA    DX, newLine
                        CALL   Print
                        LEA    DX, tryAgain
                        CALL   print
                        JMP    INPSTART
    OVERF:              
                        LEA    DX, overflowErr
                        CALL   Print
                        LEA    DX, newLine
                        CALL   Print
                        LEA    DX, tryAgain
                        CALL   print
                        JMP    INPSTART
    INPUTEND:           
                        RET
inputNumber ENDP

    ; lea dx, string and call print
print PROC
                        MOV    AH, 9
                        INT    21H
                        RET
print ENDP

    ; move number to bx and print it
printNumber proc
                        or     bx, bx
                        jns    m1
                        mov    al, '-'
                        int    29h
                        neg    bx
    m1:                 
                        mov    ax, bx
                        xor    cx, cx
                        mov    bx, 10
    m2:                 
                        xor    dx, dx
                        div    bx
                        add    dl, '0'
                        push   dx
                        inc    cx
                        test   ax, ax
                        jnz    m2
    m3:                 
                        pop    ax
                        int    29h
                        loop   m3
                        ret
printNumber endp

CSEG ENDS
END MAIN