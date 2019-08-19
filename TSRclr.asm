; multitasking TSR caller
[org 0x0100]
jmp start
; parameter block layout:
; cs,ip,ds,es,param
; 0, 2, 4, 6, 8
paramblock: times 5 dw 0 ; space for parameters
lineno: dw 0 ; line number for next thread
Acode: db '0123456789ABCDEF'
counter: dw 0x0, 0x0


task0:
hu:
jmp hu
retf



taska:
pusha
push es
lih1:
mov di, 152
xor si, si
mov dx, 0
inc word[counter]
mov bx, [counter]
;mov bx, [bp + 4]
mov ax, 0xb800
mov es, ax
mov cx, 4
number_stacker1:
mov dx, bx
and dx, 0x000F
mov si, dx
mov dx, word[Acode + si]
push dx
shr bx, 4
loop number_stacker1
mov cx, 4
mov bx, 0
number_print1:
pop  dx
mov dh, 0x07
mov [es:di], dx
add di, 2
loop number_print1
jmp lih1

;call pauser
;call pauser
;call pauser

pop es
popa
retf


taskb:
pusha
push es
lih2:
mov di, 312
xor si, si
mov dx, 0
inc word[counter]
mov bx, [counter]
;mov bx, [bp + 4]
mov ax, 0xb800
mov es, ax
mov cx, 4
number_stacker2:
mov dx, bx
and dx, 0x000F
mov si, dx
mov dx, word[Acode + si]
push dx
shr bx, 4
loop number_stacker2
mov cx, 4
mov bx, 0
number_print2:
pop  dx
mov dh, 0x07
mov [es:di], dx
add di, 2
loop number_print2
jmp lih2
pop es
popa
retf

taskc:
pusha
push es
lih3:
mov di, 472
xor si, si
mov dx, 0
inc word[counter]
mov bx, [counter]
;mov bx, [bp + 4]
mov ax, 0xb800
mov es, ax
mov cx, 4
number_stacker3:
mov dx, bx
and dx, 0x000F
mov si, dx
mov dx, word[Acode + si]
push dx
shr bx, 4
loop number_stacker3
mov cx, 4
mov bx, 0
number_print3:
pop  dx
mov dh, 0x07
mov [es:di], dx
add di, 2
loop number_print3
jmp lih3
pop es
popa
retf

taskd:
pusha
push es
lih4:
mov di, 632
xor si, si
mov dx, 0
inc word[counter]
mov bx, [counter]
;mov bx, [bp + 4]
mov ax, 0xb800
mov es, ax
mov cx, 4
number_stacker4:
mov dx, bx
and dx, 0x000F
mov si, dx
mov dx, word[Acode + si]
push dx
shr bx, 4
loop number_stacker4
mov cx, 4
mov bx, 0
number_print4:
pop  dx
mov dh, 0x07
mov [es:di], dx
add di, 2
loop number_print4
jmp lih4
pop es
popa
retf



start: 
xor ax, ax
mov [paramblock+0], cs ; code segment parameter
mov word[paramblock+2], task0
mov [paramblock+4], ds ; data segment parameter
mov [paramblock+6], es ; extra segment parameter
mov si, paramblock ; address of param block in si

mov ah, 0x4 ; SUBSERVICE FOR MAKE THREAD
int 0x80 ; multitasking kernel interrupt

call pauser ; just delays the interrupt calls for observation.


mov word[paramblock+2], taska
mov ah, 0x4
int 0x80 ; multitasking kernel interrupt
call pauser

mov word[paramblock+2], taskb
mov ah, 0x4
int 0x80 ; multitasking kernel interrupt
call pauser

mov word[paramblock+2], taskc
mov ah, 0x4
int 0x80 ; multitasking kernel interrupt
call pauser


mov word[paramblock+2], taskd
mov ah, 0x4
int 0x80 ; multitasking kernel interrupt

call pauser

; Here dx, represents the pcb number to suspend/remove/resume
mov dx, 3
mov ah, 0x03
int 0x80; remove thread

call pauser


mov dx, 1
mov ah, 0x01
int 0x80; suspend thread

call pauser
mov dx, 1
mov ah, 0x02
int 0x80; resume thread

call pauser


mov dx, start
add dx, 15
mov cl, 4
shr dx, cl
mov ax, 0x3100 ; terminate and stay resident
int 0x21

	
	
pauser:
push cx
mov cx, 0xFFFF
decr:

push cx
mov cx, 0x20
decr2:
loop decr2
pop cx

loop decr
pop cx
ret




