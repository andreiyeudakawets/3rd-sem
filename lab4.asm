.model small;   

.data
    enter_string    db 'Enter the string:', 0Dh, 0Ah, '$'
    enter_word      db 0Dh, 0Ah, 'Enter the word:', 0Dh, 0Ah, '$' 
    first_word_err  db 0Dh, 0Ah, 'Error! There is no word before the 1st. Try again:', 0Dh, 0Ah, '$'
    not_found_err   db 0Dh, 0Ah, 'Word not found or string consists of 1 word, or smth else', 0Dh, 0Ah, '$'
    result          db 0Dh, 0Ah, 'Result is:', 0Dh, 0Ah, '$' 
    
    isFound         dw 0
    size            dw 1
    check           dw 0
            
    string          db 200 dup('$') 
    word            db 200 dup('$')
     
.code 
 
printString proc
    mov ah, 09h
    int 21h
    ret 
printString endp

printString2 proc 
    call CountC   
    cont:
    cmp check, 1
    je endof 
    mov size, si
    mov ah, 02h
    lea si, string + 1
    
    printbuffer:
    inc si
    dec size
    mov dx, [si]
    int 21h 
    cmp size,0
    jne printbuffer
    inc check
    
    endof: ret
        
    ret 
printString2 endp

inputString proc
    mov ah,0Ah
    int 21h
ret
inputString endp    
          
isEmpty:      
    mov ah, [string[1]]
    cmp ah, 0
    je outputResult    
    mov al, [word[1]] 
    cmp al, 0
    je outputResult
    jmp isBigEnough  
      
isBigEnough:
    cmp ah,al
    jg findWord
    jmp outputResult
     
findWord:
    mov si, offset [string[1]]
    mov di, offset [word[2]] 
    
findFirstChar:
    call isEnd
    cmp [si], 9 ;
    je findFirstChar ;
    cmp [si], ' '
    je findFirstChar
    mov dl, [si]  
    cmp dl, [di]  
    je compareWords
    jmp skipWord
   
compareWords:
    inc di
    cmp [di], 0Dh   
    je checkEndOfWord
    call isEnd
    mov dl, [si]  
    cmp dl, [di]
    je compareWords
    mov di, offset word[2] 
    jmp skipWord 

skipWord:
    call isEnd            
    cmp [si], ' '
    je findFirstChar
    jmp skipWord

checkEndOfWord:
    call isEnd    
    cmp [si], ' '
    je findPrevWordEnd2 
    cmp [si], 13
    je findPrevWordEnd2
    mov di, offset word[2]
    jmp skipWord
   
findPrevWordStart: 
    dec si  
    cmp si, offset string[1]
    je deletePrevWord   
    cmp [si], ' '
    je deletePrevWord
    mov bx, si ;prev word 1st symbol pos  
    jmp findPrevWordStart 
      
              
findPrevWordEnd2:
    dec si 
    cmp [si-1], [offset string[1]]
    je FirstWordError 
    cmp [si], ' '
    jne findPrevWordEnd2
    mov bp, si ;prev word last symbol pos
    cmp [si-1], ' '      ;
    je  findPrevWordEnd2; 
    jmp findPrevWordStart

FirstWordError:
    mov dx, offset first_word_err
    call printString 
    jmp reenter2

WordNotFoundError:    
    mov dx, offset not_found_err
    call printString 
    jmp reenter1
                 
deletePrevWord:    
    mov isFound,1
    mov si,bp
    mov dl, [si+1]
    mov [bx], dl 
    cmp [bx], 13
    je outputResult
    inc bx
    inc bp
    jmp deletePrevWord
  
isEnd proc   ;check next symbol with cret symbol
    inc si
    cmp [si-1], 13
    je outputResult
ret
isEnd endp 
       
CountC proc    
    mov si, 0
    Flag:
    cmp [string + 2 + si], 13
    je cont
    inc si
    jmp Flag 
        
ret
CountC endp   

   
start: 
    mov ax, @data  
    mov ds, ax
    mov es, ax
    
    mov bp,0    

    reenter1:
        lea dx, enter_string
        call printString
    
        lea dx, string
        call inputString
    
        lea dx, enter_word
        call printString
    
    reenter2:
        lea dx, word
        call inputString
         
        jmp isEmpty     
     
    outputResult:    
    
        cmp isFound, 0
        je WordNotFoundError
    
        mov dx, offset result     ;output result
        call printString
           
        call printString2
    
    finale:   

end start
