
axsave equ 0
bxsave equ 2
cxsave equ 4
dxsave equ 6
sisave equ 8
disave equ 10
bpsave equ 12
spsave equ 14
ipsave equ 16
cssave equ 18
dssave equ 20
sssave equ 22
essave equ 24
flagsave equ 26
nextsave equ 28
previoussave equ 30

; multitasking and dynamic thread registration
[org 0x0100]
jmp start
; PCB layout:
; ax,bx,cx,dx,si,di,bp,sp,ip,cs,ds,ss,es,flags,next,previous
; 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24, 26 , 28 , 30
nextpcb: dw 1 ; index of next free pcb
current: dw 0 ; index of current pcb
oldisr: dd 0 ; space for saving old isr
char: db 'A'
message: db 'some random message'
temp: dw 0
Acode: db '0123456789ABCDEF'
pcb: times 32*16 dw 0 ; space for 32 PCBs
stack: times 32*256 dw 0 ; space for 32 512 byte stacks
thread_number: dw 0




ISR08:
;save_state:
push ds
push bx
push cs
pop ds
mov bx, [current]
shl bx, 5

mov [pcb + bx + axsave], ax
mov [pcb+ bx+ cxsave],cx
mov [pcb+ bx+ dxsave], dx
mov [pcb+ bx+ disave], di
mov [pcb + bx + sisave], si
mov [pcb +bx+ bpsave], bp
mov [pcb+ bx+ essave], es
pop ax
mov [pcb + bx + bxsave], ax
pop ax
mov [pcb + bx + dssave], ax
pop ax
mov [pcb + bx + ipsave], ax
pop ax
mov [pcb + bx + cssave], ax
pop ax
mov [pcb + bx + flagsave], ax
mov [pcb + bx + sssave], ss
mov [pcb + bx + spsave], sp

;get_next:
mov bx, [pcb+bx+nextsave]
mov [current], bx 
shl bx, 5 


;checking for remove
push si
push ax
mov si, [current]
shl si, 5
mov ax, [pcb + si + previoussave]
cmp ax, 2
jne kk

ht:
mov bx, [pcb + bx + nextsave]
mov [current], bx
shl bx, 5
mov ax, [pcb + bx + previoussave]
cmp ax, 2
je ht

kk:
pop ax
pop si
;--------------


;restore_state:
mov cx, [pcb + bx + cxsave]
mov dx, [pcb + bx + dxsave]
mov di, [pcb + bx +disave]
mov bp, [pcb + bx + bpsave]
mov es, [pcb + bx + essave]
mov si, [pcb + bx + sisave]
mov ss, [pcb + bx + sssave]
mov sp, [pcb + bx + spsave]
push word[pcb + bx + flagsave]
push word[pcb + bx + cssave]
push word[pcb + bx + ipsave]
push word[pcb + bx + dssave]
mov al, 0x20
out 0x20, al
mov ax, [pcb + bx + axsave]
mov bx, [pcb + bx + bxsave]
pop ds
iret






myISR:

pusha
push es
sb1:
cmp ah, 0x01
jne sb2

;SUSPEND THREAD
inc dx
mov bx, dx
shl bx, 5
mov word[cs:pcb + bx + previoussave], 2
jmp exit

sb2:
;RESUME_THREAD
cmp ah, 0x02
jne sb3
inc dx
mov bx, dx
shl bx, 5
mov word[cs:pcb + bx + previoussave], 0

jmp exit
;---------
sb3:
;REMOVE_THREAD
cmp ah, 0x03
jne sb4
inc dx
inc dx
mov bx, dx
shl bx, 5
mov si,[cs:pcb + bx + nextsave]
mov dx, si
shl si, 5
mov dx, [cs:pcb + si + nextsave]
mov word[cs:pcb + bx + nextsave], dx


jmp exit

sb4:


;INIT PCB/ MAKE THREAD
cmp ah, 0x04
jne oldisr ;this means that no subservice matched.


mov bx, [cs:nextpcb]
cmp bx, 32
je exit 
shl bx, 5 
mov ax, [si+0]
mov [cs:pcb+bx+cssave], ax
mov ax, [si+2]
mov [cs:pcb+bx+ipsave], ax
mov ax, [si+4] 
mov [cs:pcb+bx+dssave], ax
mov ax, [si+6] 
mov [cs:pcb+bx+essave], ax 
mov [cs:pcb+bx+sssave], cs  ;[cs:di] represents the stack
mov di, [cs:nextpcb] 
shl di, 9 
add di, 256*2+stack
sub di, 4 
mov [cs:pcb+bx+14], di 
mov word [cs:pcb+bx+26], 0x0200 

mov ax, [cs:pcb+nextsave] ; next of 0 pcb
mov [cs:pcb+bx+nextsave], ax ; next of new pcb
mov ax, [cs:nextpcb] ; 
mov [cs:pcb+nextsave], ax ; next of 0 pcb
inc word [cs:nextpcb]
jmp exit


oldstuff:
jmp far [cs:oldisr]
exit: 
pop es
popa
iret



start:
mov ax, 0
mov es, ax


mov ax, [es:0x80*4]
mov [oldisr], ax
mov ax, [es:0x80*4 + 2]
mov [oldisr + 2], ax


mov word [es:0x80*4], myISR
mov [es:0x80*4 + 2], cs



cli
mov word[es: 8*4], ISR08
mov [es: 8*4 +  2], cs
sti


mov dx, start
add dx, 15
mov cl, 4
shr dx, cl
mov ax, 0x3100 ; terminate and stay resident
int 0x21


clear_screen:
 push ax
 push cx
 push di
 push es
 
   mov ax , 0xB800
   mov es , ax
   mov di , 0
   mov ax , 0x0720
   mov cx , 2000
   rep stosw
   
   pop es
   pop di
   pop cx
   pop ax
ret




