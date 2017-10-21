[bits 32]

clear_screen:
mov bx,1
lable1:
mov byte [gs:bx],0x00
add bx , 2
cmp bx,3999
je finish1
jmp lable1
finish1:
  mov bx,0
  mov si,0
  mov di,0
  ret	

put_char:
mov byte [gs:di],al
inc di
mov byte [gs:di],0x0f
inc di
ret 

print_screen:
;lea bx,temp
call set_cursor
again:
mov al,[bx]
mov byte[gs:di],al
inc di
inc bx 
mov byte[gs:di],0x0f
inc di
cmp  byte [bx],0
je finish2
jmp again
finish2:
  ret

get_app:
   keyp:
	 in al,60h
	 test al,80h
	 jnz keyp
	 and al,7fh
	 mov bx,apptable
	 dec al
	 xlat
	 cmp al,'1'
	 je calculator
	 cmp al,'2'
	 je text_editor
	 cmp al,'3'
	 je paint
	 cmp al,'4'
	 je info
	 cmp al,10
	 je shutdown
     cmp al,0
	 je keyu
	 keyu:
	 in al,60h
	test al,80h
	jz keyu
	jmp keyp
  
info:
   call clear_screen
   mov bx,infofile
   call print_screen
   mov di,2
   mov si,3
   mov bx,infofile2
   call print_screen
   mov di,2
   mov si,5
   mov bx,infofile3
   call print_screen
   keyp1:
	 in al,60h
	 test al,80h
	 jnz keyp1
	 and al,7fh
	 mov bx,tablecal
	 dec al
	 xlat
	 cmp al,1
	 je gomain
     cmp al,0
	 je keyu1
	 keyu1:
	 in al,60h
	test al,80h
	jz keyu1
	jmp keyp1
 gomain:
   call kernel_start 
   
set_cursor: ;si = row di = column ;position (row *160) + (column*2)    
      push ax
	  push bx
	  push dx
	  mov ax,si
	  mov bl,160
	  mul bl ;row*160
	  mov dx,ax 
	  mov ax,di
	  mov bl,2
	  mul bl ;column*2
	  add ax,dx 
	  mov di,ax
	  pop dx
	  pop bx
	  pop ax
	  ret
	  
paint:     
kp:
	in al,60h
	test al,80h
	jz kp
     call clear_screen
     mov dl,0x0f
	 mov bx,msg10
	 call print_screen
	 mov di,1	 
     mov si,4
     call set_cursor
	 
    keypaint:
	 in al,60h
	 test al,80h
	 jNz keypaint
     
	 and al,7fh
	 
	 dec AL
 mov bx,tablepaint
	 xlat
	 cmp al,1
	 je exit_paint
	 cmp al,0
	 je keypaintup
	 cmp al,'1'
	 je paintblue
	 cmp al,'2'
	 je paintgreen
	 cmp al,'3'
	 je paintcyan
	 cmp al,'4'
	 je paintred
	 cmp al,'5'
	 je paintmagneta
	 cmp al,'6'
	 je paintbrown
	 cmp al,'7'
	 je paintyellow
	 cmp al,'8'
	 je paintwhite
	 cmp al,'9'
	 je eraser
	 cmp al,'a'
     je left
     cmp al,'d'
     je right	
     cmp al,'w'
     je up	
     cmp al,'s'
     je down		 
keypaintup:
	in al,60h
	test al,80h
	jz keypaintup
	jmp keypaint

eraser:
      mov dl,0x00
	  jmp keypaintup
paintwhite:
      mov dl,0x0f
	  jmp keypaintup
paintyellow:
      mov dl,0x0E
	  jmp keypaintup
paintbrown:
      mov dl,0x06
	  jmp keypaintup
paintmagneta:
      mov dl,0x05
	  jmp keypaintup
paintred:
      mov dl,0x04
	  jmp keypaintup
paintcyan:
      mov dl,0x03
	  jmp keypaintup	
paintgreen:
      mov dl,0x02
	  jmp keypaintup
paintblue:
      mov dl,0x01
      jmp keypaintup
	  
putchar_paint:
mov byte [gs:di],0x08
inc di
mov byte [gs:di],dl
inc di
ret 

 exit_paint:
    call clear_screen
	call kernel_start
left:
     cmp di,162
	 jg goleft
	 jmp keypaintup
goleft:     
     sub di,4	  
	 call putchar_paint
	 jmp keypaintup
right:
      cmp di,3840
	  jl goright
	  jmp keypaintup
goright:
	  
      call putchar_paint
      jmp keypaintup
up:
     cmp di,320
	 jge goup
	 jmp keypaintup
goup:	 
     sub di,162
	 call putchar_paint
     jmp keypaintup
down:
     cmp di,3840
	 jle godown
	 jmp keypaintup
godown:	 
	 add di,158
     call putchar_paint
     jmp keypaintup
	 
calculator:
phase_1:
		keyup:	   
		in al,60h
		test al,80h
		jz keyup

     call clear_screen
	 mov bx,msg5
	 call print_screen
	 inc si
	 mov di,0
	 mov bx,msg6
	 call print_screen
	 inc si
	 mov di,0
	 call set_cursor
	 calkey:
	 in al,60h
	 test al,80h
	 jnz calkey
	 
	 and al,7fh
	 mov bx,tablecal
	 dec al
	 xlat
	 cmp al,0
	 je keycal
	 cmp al,0x1C
	 je phase_2
	 cmp al,1
	 je exitcal
	 call put_char
	 inc dx
	keycal:	   
	in al,60h
	test al,80h
	jz keycal
	jmp calkey
phase_2:
     keyup1:	   
	in al,60h
	test al,80h
	jz keyup1

     inc si
	 mov di,0
	 mov bx,msg7
	 call print_screen
	 inc si
	 mov di,0
	 call set_cursor
    calkey2:
	 in al,60h
	 test al,80h
	 jnz calkey2
	 
	 and al,7fh
	 mov bx,tablecal
	 dec al
	 xlat
	 cmp al,0
	 je keycal2
	 cmp al,0x1C
	 je phase_3
	 
	 cmp al,1
	 je exitcal
	 call put_char
     
	keycal2:	   
	in al,60h
	test al,80h
	jz keycal2
	jmp calkey2
phase_3:
    keyup3:	   
	in al,60h
	test al,80h
	jz keyup3

     inc si
	 mov di,0
	 mov bx,msg8
	 call print_screen
	 inc si
	 mov di,0
	 call set_cursor
         calkey3:
	 in al,60h
	 test al,80h
	 jnz calkey3
	 
	 and al,7fh
	 mov bx,tablecal
	 dec al
	 xlat
	 cmp al,0
	 je keycal3
	 
	 cmp al,1
	 je exitcal
	keycal3:	   
	in al,60h
	test al,80h
	jz keycal3
	jmp calkey3
	exitcal:
	  call kernel_start
text_editor:
	 key1:
	 in al,60h
	 test al,80h
	 jz key1
     call clear_screen
	 mov bx,msg4
	 call print_screen
	 inc si
	 mov di,0
	 mov bx,msg3
	 call print_screen
	 inc si
	 mov di,0
	 call set_cursor
     keypressed:
	 in al,60h
	 test al,80h
	 jnz keypressed
	 
	 and al,7fh
	 mov bx,table
	 dec al
	 xlat
	 cmp al,0
	 je key
	 
	 cmp al,0x0e
	 je back_space
	 
	 cmp al,0x1C
	 je newline
	 
	 cmp al,0x01
	 je exit
	 cmp al,0x0f
	 je tab
	 call put_char
     jmp key
	 
back_space:
        push ax
		push bx
		push dx
       mov ax,di
	   mov bx,160
	   mov dx,0
	   div bx
	   cmp dx,0
	   jne back
	   pop dx
	   pop bx
	   pop ax
	   JMP perv_line
back:
      pop dx
      pop bx
      pop ax	  
       sub di,2
       mov al,' '
       call put_char
	   sub di,2
       jmp key
tab:
    mov al,' '
	call put_char
    mov al,' '
	call put_char
	jmp key	
newline:
      inc si
	  mov dx,di
      mov di,0
      call set_cursor
	  jmp key
exit:
    call kernel_start
perv_line:
    cmp di,320
    jg line_up
	jmp key

line_up:

     mov di,dx
     jmp key
key:
	in al,60h
	test al,80h
	jz key
	jmp keypressed 
shutdown:
call clear_screen	
jmp $

table db 0x01,"1234567890-=",0X0E,0x0F,'qwertyuiop[]',0x1C,0,"asdfghjkl;'",0,0,0,"zxcvbnm,./",0,0,0," ",0
apptable db 10,"1234",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
tablecal db 1,"1234567890",0,0,0,0,1,2,3,4,0,0,0,0,0,0,0,0,0x1c,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
tablepaint db 0x01,"1234567890-=",0X0E,0x0F,'qwertyuiop[]',0x1C,0,"asdfghjkl;'",0,0,0,"zxcvbnm,./",0,0,0," ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x1e,0x1f,0x20,0x21
string db 10,13,0
num1 db 0,0,0,0,0,0,0,0,0,0 
num2 db 0,0,0,0,0,0,0,0,0,0
msg3 db "Text editor:",0
msg4 db "Press ESC to Exit",0
msg5 db "Calculator",0
msg6 db "Enter your first number:",0
msg7 db "Enter your second number:",0
msg8 db "Choose Your Operation: (q = +) (w = -) (e = *) (r = /)",0
msg10 db "1.Blue 2.Green 3.Cyan 4.Red 5.Magneta 6.Brown 7.Yellow 8.White 9.Eraser ESC:Exit",0
infofile db "This Os was Made By Hooman Malekzadeh and Ali Delkhosh",0
infofile2 db "Shiraz University all rights reserved",0
infofile3 db "Press Esc to Return",0