extern ExitProcess, GetStdHandle, WriteConsoleA
global start
%include "invoke.inc"



section .data
	STD_OUTPUT_HANDLE equ -11
	year1 equ 1800
	year2 equ 2020
	
	 struc list_t
		author: resb 32
		bookname: resb 32
		year: resw 1
		next: resd 1
	endstruc
	
	head: istruc list_t
		at author, db "Vasiliy Pushkin"
		at bookname, db "Andrew Black"
		at year, dw 1982
		at next, dd test2
	iend
	
	test2: istruc list_t
		at author, db 0
		at bookname, db 0
		at year, dw 1999
		at next, dd test3
	iend
	
	test3: istruc list_t
		at author, db "Haruki Murakami"
		at bookname, db "Nejimaki Tori Kuronikuru"
		at year, dw 2000
		at next, dd test4
	iend
	
	test4: istruc list_t
		at author, db "Haruki Murakami"
		at bookname, db "1Q84"
		at year, dw 200
		at next, dd 0
	iend
	
	newline db 10
	
	
section .code
start:
	;call out_list
	call search_delete
	call out_list
	invoke ExitProcess, 0
	
out_list:
	push eax
	push ebx
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov ebx, eax
	mov esi, head
	.cycle:
		invoke WriteConsoleA, ebx, esi+author, 32, 0, 0
		invoke WriteConsoleA, ebx, newline, 1, 0, 0
		add esi, bookname
		invoke WriteConsoleA, ebx, esi, 32, 0, 0
		sub esi, bookname
		invoke WriteConsoleA, ebx, newline, 1, 0, 0
		cmp dword[esi+next], 0
		je .ext
		mov esi, dword[esi+next]
		jmp .cycle
	.ext:
	pop ebx
	pop eax
	
search_delete:
	push eax
	push ebp
	mov ebp, esp
	xor eax, eax
	mov esi, head
	mov eax, dword[esi+year];
	
	listmove:
		cmp byte[esi+author], 0 ; if first symbol of author is 0
		je .delete
		cmp byte[esi+bookname], 0 ; and fs of bookname is 0
		jne .checkyear
		
		.delete: ; delete 
		   cmp esi, head; if current != head
		   jne .delnext ; then work with stack
		   ;else head will be next elem of list
		   mov edi, dword [esi+next]
		   mov dword[head], edi
		   push head
		   jmp .step1np  	
		   
		.delnext:
		   pop edi; if it's not head pop prev element
		   mov eax, dword[esi+next] 
		   mov dword[edi+next], eax
		   push esi
		   jmp .step1np	   	   
		;
		.checkyear:
			cmp word[esi + year], year1
			jb .delete
			cmp word[esi + year], year2
			ja .delete
		
		.step1withpush:
		push esi ; save prev element
		.step1np:
		cmp dword[esi+next], 0 ; if test[i]==nullptr
		je .ext ; leave cycle
		mov esi, dword [esi+next] ; else eax = test[i].next
		jmp listmove
		
		
		
	.ext:
		mov esp, ebp
		pop ebp
		pop eax
		ret
