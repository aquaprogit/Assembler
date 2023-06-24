STSEG SEGMENT PARA STACK "STACK"
        DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA "DATA"
  inputValue    DB 7, ?, 7 DUP ( 0 )
  number        DW 0
  isNegative    DB 0
  increaseValue DW 78
  label1        DB "ENTER NUMBER [-32 767; 32 689]: $"
  label2        DB "ENTER INCREASE VALUE: $"
  formatErr     DB "Incorrect input!$"
  overflowErr   DB "Overflow error!$"
  newLine       DB 10, 13, "$"
DSEG ENDS

CSEG SEGMENT PARA "CODE"
MAIN PROC FAR
              ASSUME CS:CSEG, DS:DSEG, SS:STSEG

              PUSH   DS
              XOR    AX, AX
              PUSH   AX
              MOV    AX, DSEG
              MOV    DS, AX
  ;----------------------------------------------
  MAINSTART:  
              MOV    AL, label2
              MOV    label1, AL
              CALL   Input
              MOV    AX, number
              ADD    AX, increaseValue
              JO     OVERFL
              JMP    MAINEND
  OVERFL:     
              LEA    DX, overflowErr
              CALL   Print
              LEA    DX, newLine
              CALL   Print
              JMP    MAINSTART
  MAINEND:    
              MOV    number, AX

              CALL   printNumber
  ;----------------------------------------------
              RET
MAIN ENDP

Input PROC
  INPSTART:   
              LEA    DX, label1
              CALL   Print

              LEA    DX, inputValue
              MOV    AH, 10
              INT    21H

              LEA    DX, newLine
              CALL   Print

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
              JMP    INPSTART
  OVERF:      
              LEA    DX, overflowErr
              CALL   Print
              LEA    DX, newLine
              CALL   Print
              JMP    INPSTART
  INPUTEND:   
              MOV    number, AX
              RET
INPUT ENDP

Print PROC
              MOV    AH, 9
              INT    21H
              RET
Print ENDP

printNumber proc
              mov    bx, number
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
