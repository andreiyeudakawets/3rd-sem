 org $8000 
 ldab #$00 
 ldy #$00
 ldx #$8200 
loop ldab 0,x 
 inx
 orab #%11111110
 cmpb #%11111111
 bne aplus
 iny
aplus  
 cmpx #$8300
 bne loop
end
	