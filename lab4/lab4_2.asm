STSEG SEGMENT PARA STACK "STACK"
          DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA "DATA"
    arr                DW 100 DUP ( ? )
    rowsCount          DW 0
    colsCount          DW 0
    valueFound         DB 0
    row                DW 0
    column             DW 0

    inputValue         DB 7, ?, 7 DUP ( 0 )
    newLine            DB 10, 13, "$"
    Number             DW 0

    isNegative         DB 0
    rowsCountLabel     DB 'Enter rows count: $'
    colsCountLabel     DB 'Enter columns count: $'
    elementSizeLabel   DB 'Enter element in range [-32767; 32767]:', 10, 13, '$'
    enterElementStart  DB 'Enter element at [', '$'
    enterElementMiddle DB '][', '$'
    enterElementEnd    DB ']: ', '$'
    enterValueToFind   DB 'Enter value to find: $'
    valueNotFoundLabel DB 'Value not found!', 10, 13, '$'
    valueFoundLabel    DB 'Value found at [', '$'
    valueFoundMiddle   DB '][', '$'
    valueFoundEnd      DB ']', '$'
    outOfBounds        DB 'Out of bounds!', 10, 13, '$'
    formatErr          DB 'Incorrect format!', 10, 13, '$'
    overflowErr        DB 'Overflow error!', 10, 13, '$'
    tryAgain           DB 'Try again: $'

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
    ;---------------------------------
                     call   getRows
                     call   getColumns

                     LEA    DX, elementSizeLabel
                     CALL   print

                     call   readMatrix

                     LEA    DX, enterValueToFind
                     CALL   print
                     MOV    Number, 0
                     CALL   inputNumber
                     call   findValueIndexes

    ENDProg:         
                     RET
MAIN ENDP

findValueIndexes PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   SI
                     PUSH   DI
	
                     MOV    CX, rowsCount
                     LEA    SI, arr
                     MOV    BX, 1
    OuterFindLoop:   
                     MOV    DI, 1
    InnerFindLoop:   
                     MOV    AX, [SI]
                     CMP    Number, AX
                     JNE    MoveNext
		
                     MOV    valueFound, 1
                     MOV    row, BX
                     MOV    column, DI
                     CALL   printFoundCoords
		
    MoveNext:        
                     ADD    SI, TYPE arr
                     INC    DI
                     CMP    DI, colsCount
                     JLE    InnerFindLoop
		
    InnerFindLoopEnd:
                     INC    BX
                     LOOP   OuterFindLoop
	
                     CMP    valueFound, 1
                     JE     FindEnd
                     LEA    DX, valueNotFoundLabel
                     CALL   print
                     LEA    DX, newLine
                     CALL   print
	
    FindEnd:         
                     POP    DI
                     POP    SI
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
findValueIndexes ENDP

printFoundCoords PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                     PUSH   DI
    
                     LEA    DX, valueFoundLabel
                     CALL   print
                     MOV    AX, row
                     MOV    Number, AX
                     CALL   printNumber
                     LEA    DX, valueFoundMiddle
                     CALL   print
                     MOV    AX, column
                     MOV    Number, AX
                     CALL   printNumber
                     LEA    DX, valueFoundEnd
                     CALL   print
    
                     POP    DI
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
printFoundCoords ENDP

getDimentionSize PROC
    DIM_SIZE_START:  
                     call   inputNumber
                     cmp    Number, 0
                     jle    INCORRECT_DIM
                     cmp    Number, 10
                     jg     INCORRECT_DIM
                     jmp    DIM_SIZE_END

    INCORRECT_DIM:   
                     lea    dx, outOfBounds
                     call   print
                     lea    dx, tryAgain
                     call   print
                     jmp    DIM_SIZE_START
    DIM_SIZE_END:    
                     RET
getDimentionSize ENDP

getRows PROC
                     PUSH   AX
                     PUSH   DX
                     lea    dx, rowsCountLabel
                     call   print
                     call   getDimentionSize
                     mov    AX, Number
                     mov    rowsCount, AX
                     POP    DX
                     POP    AX
                     RET
getRows ENDP
getColumns PROC

                     PUSH   AX
                     PUSH   DX
                     lea    dx, colsCountLabel
                     call   print
                     call   getDimentionSize
                     mov    AX, Number
                     mov    colsCount, AX
                     POP    DX
                     POP    AX
                     RET
getColumns ENDP

readMatrix PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                     PUSH   DI
	
                     XOR    SI, SI
                     MOV    CX, rowsCount
                     MOV    BX, 1
	
    OuterReadLoop:   
                     MOV    DI, 1
    InnerReadLoop:   
                     LEA    DX, enterElementStart
                     CALL   print
                     MOV    Number, BX
                     CALL   printNumber
                     LEA    DX, enterElementMiddle
                     CALL   print

                     MOV    Number, DI
                     CALL   printNumber
                     LEA    DX, enterElementEnd
                     CALL   print
		
                     MOV    Number, 0
                     CALL   inputNumber

                     MOV    AX, Number
                     MOV    arr[SI], AX
                     ADD    SI, TYPE arr
                     INC    DI
                     CMP    DI, colsCount
                     JLE    InnerReadLoop
			
    InnerReadLoopEnd:
                     INC    BX
                     LOOP   OuterReadLoop
	
                     POP    DI
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
readMatrix ENDP

    ; return value in numberFromUser
inputNumber PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
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
                     CALL   print
                     LEA    DX, tryAgain
                     CALL   print
                     JMP    INPSTART
    OVERF:           
                     LEA    DX, overflowErr
                     CALL   print
                     LEA    DX, tryAgain
                     CALL   print
                     JMP    INPSTART
    INPUTEND:        
                     MOV    Number, 0
                     MOV    Number, AX
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
inputNumber ENDP
    ; move number to Number and print it
printNumber proc
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     mov    bx, Number
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
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     ret
                     
printNumber endp
    ; lea dx, string and call print
print PROC
                     MOV    AH, 9
                     INT    21H
                     RET
print ENDP


CSEG ENDS
END MAIN