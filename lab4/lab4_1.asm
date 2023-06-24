STSEG SEGMENT PARA STACK "STACK"
          DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA "DATA"
    arrSize          DW 0
    arr              DW 100 DUP ( ? )
    max              DW 0
    min              DW 0
    sum              DW 0
    sumError         DB 0
    inputValue       DB 7, ?, 7 DUP ( 0 )
    newLine          DB 10, 13, "$"
    Number           DW 0

    isNegative       DB 0
    arrSizeLabel     DB 'Enter array size [1; 100]: $'
    maxLabel         DB 'Max: $'
    minLabel         DB 'Min: $'
    sortedArrLabel   DB 'Sorted array: $'
    sumLabel         DB 'Sum: $'
    arrElementLabelS DB 'Enter array element [$'
    arrElementLabelE DB ']: $'
    inputArrayLabel  DB 'Entered array elements: $'
    delimiter        DB ' ', '$'
    elementSizeLabel DB 'Enter element in range [-32767; 32767]: $'
    sumErrorLabel    DB 'Sum was out of bounds: $'
    outOfBounds      DB 'Out of bounds!', 10, 13, '$'
    formatErr        DB 'Incorrect format!', 10, 13, '$'
    overflowErr      DB 'Overflow error!', 10, 13, '$'
    tryAgain         DB 'Try again: $'

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
                     call   inputArray

                     LEA    DX, newLine
                     CALL   print

                     LEA    DX, inputArrayLabel
                     CALL   print
                     call   printArr

                     call   printSum
                     
                     call   printMax
                     call   printMin

                     call   sortArr
                     call   printArr



    ENDProg:         
                     RET
MAIN ENDP

printSum PROC
                     LEA    DX, sumLabel
                     CALL   print
                     call   getSum
                     CMP    sumError, 1
                     JE     SUM_ERR
                     MOV    AX, sum
                     MOV    Number, AX
                     CALL   printNumber
                     JMP    SUM_END
    SUM_ERR:         
                     LEA    DX, sumErrorLabel
                     CALL   print
    SUM_END:         
                     LEA    DX, newLine
                     CALL   print
                     RET
printSum ENDP

getSum PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                     PUSH   DI
                     PUSH   BP

                     MOV    sumError, 0
                     XOR    SI, SI
                     MOV    CX, arrSize
                     XOR    BX, BX
                     XOR    BP, BP
                     XOR    DI, DI

    START_GET_SUM:   
                     MOV    AX, arr[SI]
                     ADD    sum, AX
                     JO     OVERFL
                     INC    BX
                     ADD    SI, TYPE arr
                     LOOP   START_GET_SUM
                     JMP    END_GET_SUM
    OVERFL:          
                     MOV    sumError, 1
    END_GET_SUM:     

                     POP    BP
                     POP    DI
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     ret
getSum endp

sortArr PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
    
                     LEA    DX, sortedArrLabel
                     CALL   print
    
                     CMP    arrSize, 1
                     JE     SORT_END
                    
                     MOV    Number, 0
                     MOV    CX, arrSize
                     DEC    CX
    OUT_LOOP:        
                     XOR    BX, BX
		
    IN_LOOP:         
                     MOV    AX, TYPE arr
                     MUL    BX
                     MOV    SI, AX
			
                     MOV    AX, arr[SI]
                     MOV    DX, arr[SI + TYPE arr]
                     CMP    AX, DX
                     JLE    CONTINUE
                     MOV    arr[SI], DX
                     MOV    arr[SI + TYPE arr], AX
		
    CONTINUE:        
                     INC    BX
                     CMP    BX, CX
                     JL     IN_LOOP
                     LOOP   OUT_LOOP


    SORT_END:        
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
sortArr ENDP

printMax PROC
                     LEA    DX, maxLabel
                     CALL   print
                        
                     call   getMax
                     MOV    AX, max
                     MOV    Number, AX
                     CALL   printNumber
                        
                     LEA    DX, newLine
                     CALL   print
                     RET
printMax ENDP

printMin proc
                     LEA    DX, minLabel
                     CALL   print
                            
                     call   getMin
                     MOV    AX, min
                     MOV    Number, AX
                     CALL   printNumber
                            
                     LEA    DX, newLine
                     CALL   print
                     RET
printMin ENDP

getMax proc
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                        
                     XOR    SI, SI
                     MOV    CX, arrSize
                     XOR    BX, BX
                        
                     MOV    AX, arr
                     MOV    max, AX
    START_GET_MAX:   
                     MOV    AX, arr[SI]
                     CMP    AX, max
                     JLE    SKIP_MAX
                     MOV    max, AX
    SKIP_MAX:        
                     ADD    SI, TYPE arr
                     INC    BX
                        
                     LOOP   START_GET_MAX
                        
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     ret
getMax endp
getMin proc
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                            
                     XOR    SI, SI
                     MOV    CX, arrSize
                     XOR    BX, BX
                            
                     MOV    AX, arr
                     MOV    min, AX
    START_GET_MIN:   
                     MOV    AX, arr[SI]
                     CMP    AX, min
                     JGE    SKIP_MIN
                     MOV    min, AX
    SKIP_MIN:        
                     ADD    SI, TYPE arr
                     INC    BX
                            
                     LOOP   START_GET_MIN
                            
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     ret
getMin endp

printArr PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI

                     XOR    SI, SI
                     MOV    CX, arrSize
                     XOR    BX, BX

    START_PRINT_ARR: 
                     MOV    AX, arr[SI]
                     MOV    Number, AX
                     CALL   printNumber

                     LEA    DX, delimiter
                     CALL   print
                     
                     ADD    SI, TYPE arr
                     INC    BX
                     
                     LOOP   start_print_arr
                     
                     LEA    DX, newLine
                     CALL   print

                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX

                     RET
printArr ENDP

inputArray PROC
                     call   inputArrSize
                     LEA    DX, elementSizeLabel
                     CALL   print
                     LEA    DX, newLine
                     CALL   print
                     call   inputArrElements
                     RET
inputArray ENDP

inputArrElements PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
	
                     XOR    SI, SI
                     MOV    CX, arrSize
                     MOV    BX, 1
	
    ReadLoop:        
                     LEA    DX, arrElementLabelS
                     CALL   print
                     MOV    Number, BX
                     CALL   printNumber
                     LEA    DX, arrElementLabelE
                     CALL   print
		
                     MOV    Number, 0
                     CALL   inputNumber
		
                     MOV    AX, Number
                     MOV    arr[SI], AX
                     ADD    SI, TYPE arr
                     INC    BX
                     LOOP   ReadLoop

                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
inputArrElements ENDP
inputArrSize PROC
    START_ARR_SIZE:  
                     LEA    DX, arrSizeLabel
                     CALL   print
                     CALL   inputNumber
                     CMP    Number, 0
                     JLE    OUT_OF_BOUNDS
                     CMP    Number, 100
                     JG     OUT_OF_BOUNDS
                     JMP    END_ARR_SIZE
    OUT_OF_BOUNDS:   
                     LEA    DX, outOfBounds
                     CALL   print
                     JMP    START_ARR_SIZE
    END_ARR_SIZE:    
                     MOV    AX, Number
                     MOV    arrSize, AX
                     RET
inputArrSize ENDP
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