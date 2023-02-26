.model small
.stack 100h

.data
	password db '123456$'
	password_length db $ - password

	msg_input_password		db         '***************************Please Enter Your Password***************************$'
	msg_incorrect_password	db 0Ah,0Dh,'*******************************Incorrect Password*******************************$'

	msg_welcome			db 0Ah,0Dh, '***************************WELCOME TO MEDICAL DISPENSER***************************$'
	msg_choose_option	db 0Ah,0Dh, 'Choose an Option$'
	msg_what_to_buy		db 0Ah,0Dh, '*****************************What do you want to buy?*****************************$'

	msg_opt_1	db 0Ah,0Dh,'Press  1  to buy medicines$'
	msg_opt_2	db 0Ah,0Dh,'Press  2  to see medicines statistics$'
	msg_opt_3	db 0Ah,0Dh,'Press  3  to show amount earned today$'
	msg_opt_4	db 0Ah,0Dh,'Press  4  to refill medicines$'
	msg_opt_5	db 0Ah,0Dh,'Press  5  to exit$'

	msg_input_again		db 0Ah,0Dh,'Please press one of the mentioned keys$'
	msg_invalid_input	db 0Ah,0Dh,'Invalid input entered!$'

	medicine_length equ 7
	medicine_array	db	'Panadol$$$$$$$$$$$', 0
					db	'Paracetamol$$$$$$$', 0
					db	'Cleritek$$$$$$$$$$', 0
					db	'Aspirin$$$$$$$$$$$', 0
					db	'Brufen$$$$$$$$$$$$', 0
					db	'Surbex Z$$$$$$$$$$', 0
					db	'Arinac$$$$$$$$$$$$', 0
	medicine_price	db  2, 4, 6, 8, 7, 5, 3
	medicine_amount	db  9, 8, 7, 6, 5, 4, 2
	medicine_sold	db  0, 0, 0, 0, 0, 0, 0
	medicine_max	equ 10d
	msg_seperator_1	db  '. $'
	msg_seperator_2	db  ' - $'
	msg_quantity	db  ' - Quantity: $'

	msg_out_of_stock	db  ' is out of stock!$'
	msg_fewer_stock		db  ' does not have sufficient stock!$'
	medicine_index	db  1

	msg_new_line	db 0Ah,0Dh,'$'
	msg_pkr			db         'PKR$'

	msg_how_many   db 0Ah,0Dh,'How many $'
	msg_to_buy     db		  ' do you want to buy?$'
	msg_total_earn db		  'Total Earned = $'
	amount db 0

	msg_sold     db ' sold = $'
	msg_refilled db 'All medicines have been refilled!$'

	value    db 0
	hundreds db 0
	tens     db 0
	units    db 0

.code
main proc
	mov ax, @data
	mov ds, ax
	
	start:
		call menu

	call printNewLine
	
	call inputNumber
	
	cmp al,'1'
	je menu2
	cmp al,'2'
	je medicines_stats
	cmp al,'3'
	je show_amount
	cmp al, '4'
	je refill_medicines
	cmp al,'5'
	je exit

	invalidInput:
		lea dx, msg_invalid_input
		call printString
		lea dx, msg_input_again
		call printString
		jmp start

	outOfStock:
		call printNewLine

		mov  ah, 0
		mov  al, medicine_index
		mov  dl, 13h
		mul  dl
		mov  si, offset medicine_array
		mov  dh, 0
		add  si, ax
		mov  dx, si
		call printString

		lea dx, msg_fewer_stock
		call printString
		jmp start

	show_amount:
		call inputPassword
		call printNewLine 
		lea dx, msg_total_earn
		call printString

		mov dl, amount
		mov value, dl
		call printValue

		lea dx, msg_pkr
		call printString

		jmp start

	refill_medicines:
		call inputPassword
		call printNewLine
		mov cx, medicine_length
		mov di, offset medicine_amount
		mov bl, medicine_max
		refill_loop:
			mov [di], bl
			inc di
			loop refill_loop
		lea dx, msg_refilled
		call printString
		call printNewLine
		jmp start
	
	incorrect:
		lea dx, msg_incorrect_password
		call printString
		jmp start

	exit:
		mov ah,4ch
		int 21h
main endp

inputPassword proc
	call printNewLine
	lea dx, msg_input_password
	call printString

	mov bx, offset password
	mov ch, 0
	mov cl, password_length
	call printNewLine
		
	l1:
		call inputNumber
		cmp al,[bx]
		jne incorrect
		inc bx
		loop l1
	ret
inputPassword endp

menu proc
	lea dx, msg_welcome
	call printString

	lea dx, msg_choose_option
	call printString

	lea dx, msg_opt_1
	call printString

	lea dx, msg_opt_2
	call printString

	lea dx, msg_opt_3
	call printString
	
	lea dx, msg_opt_4
	call printString

	lea dx, msg_opt_5
	call printString
	ret
menu endp

menu2 proc
	lea dx, msg_what_to_buy
	call printString
	
	mov si, offset medicine_array
	mov di, offset medicine_price
	mov bx, offset medicine_amount
	mov cx, medicine_length
	mov medicine_index, 1

	printArrays:
		mov dl, medicine_index
		add dl, 30h
		call printNumber
		inc medicine_index

		lea dx, msg_seperator_1
		call printString

		mov dx, si
		call printString
		add si, 13h

		lea dx, msg_seperator_2
		call printString

		mov dl, [di]
		add dl, 30h
		call printNumber
		inc di

		lea dx, msg_pkr
		call printString

		lea dx, msg_quantity
		call printString

		mov dl, [bx]
		mov value, dl
		call printValue
		inc bx

		call printNewLine

		loop printArrays

	call printNewLine
	
	call inputNumber
	sub  al, 30h
	call invalidMedicineCheck

	sub  al, 01h
	mov  medicine_index, al

	mov si, offset medicine_amount
	mov dx, 0
	mov dl, medicine_index
	add si, dx
	cmp [si], 0
	je  outOfStock

	mov  dx, offset msg_how_many
	call printString

	mov  ah, 0
	mov  al, medicine_index
	mov  dl, 13h
	mul  dl
	mov  si, offset medicine_array
	mov  dh, 0
	add  si, ax
	mov  dx, si
	call printString

	lea dx, msg_to_buy
	call printString

	call printNewLine

	call inputNumber
	sub al, 30h

	;; If AL < '0' goto invalidInput
	cmp al, 0
	jb  invalidInput
	;; If AL < '9', goto invalidInput
	cmp al, 9
	ja  invalidInput

	;; Out of Stock checking...
	mov bl, al ;; Load the value of the userInput variable into BL
	mov si, offset medicine_amount ;; Load the offset of medicine_amount
	mov dx, 0
	mov dl, medicine_index
	add si, dx
	mov bh, [si]
	cmp bl, bh ;; Compare the values in BL and [SI]
	ja  outOfStock ;; If the value in BL is greater than the value in [SI], jump to the outOfStock label

	;; Stock amount changes...
	sub bh, bl ;; Otherwise, subtract the value in BL from the value in BH

	mov si, offset medicine_amount ;; Initialize SI with the address of the medicine_amount array
	mov dl, medicine_index ;; Store the value of medicine_index to DL
	add si, dx ;; Add the medicine_index to DL to get the address of the desired element
	mov [si], bh ;; Store the result back in the medicine_index of the medicine_amount array

	;; Stock sold changes...
	mov si, offset medicine_sold ;; Store the offset of medicine_sold array into SI
	mov dl, medicine_index
	add si, dx
	add [si], bl ;; Add the amount sold to array

	;; Calculate price...
	mov bh, 0
	mov bl, al
	mov si, offset medicine_price
	mov dx, 0
	mov dl, medicine_index
	add si, dx
	mov ax, [si]
	mul bx

	add amount, al
	mov cl, al

	call printNewLine

	lea dx, msg_total_earn
	call printString

	mov value, cl
	call printValue

	jmp start
	ret
menu2 endp

medicines_stats proc
	call inputPassword
	mov si, offset medicine_array
	mov bx, offset medicine_sold
	mov cx, medicine_length
	mov medicine_index, 1

	call printNewLine
	printSales:
		mov dx, si
		call printString
		add si, 13h

		lea dx, msg_sold
		call printString

		mov dl, [bx]
		mov value, dl
		call printValue
		inc bx

		call printNewLine

		loop printSales

	jmp start
	ret
medicines_stats endp

inputNumber proc
	mov ah, 1
	int 21h
	ret
inputNumber endp

printNumber proc
	mov ah, 2
	int 21h
	ret
printNumber endp

printString proc
	mov ah, 9
	int 21h
	ret
printString endp

printNewLine proc
	lea dx, msg_new_line
	mov ah, 9
	int 21h
	ret
printNewLine endp

printValue proc
	;; we can not MOV from memory to memory, must move to register first
	mov dl, value
	mov units, dl

	;; reset value of tens to 0
	mov tens, 0
	;; reset value of hundreds to 0
	mov hundreds, 0

	;; hundreds checker
	hundredsCounter:
		;; if units < 100, goto tensCounter
		cmp units, 100
		jb  tensCounter

		;; else
		sub units, 100
		inc hundreds
		jmp hundredsCounter
	
	tensCounter:
		;; if units < 10, goto hundredsPrinter
		cmp units, 10
		jb  hundredsPrinter

		;; else
		sub units, 10
		inc tens
		jmp tensCounter
	
	hundredsPrinter:
		;; if hundreds == 0, GOTO checkTens
		;; because value could be in tens
		cmp hundreds, 0
		jz  checkTens

		;; else
		mov dl, hundreds
		add dl, 30h
		call printNumber
		jmp tensPrinter

	checkTens:
		;; if tens == 0, goto unitsPrinter
		cmp tens, 0
		jz  unitsPrinter

	tensPrinter:
		;; always print tens if hundred != 0
		;; JMPs here from hundredsPrinter
		mov dl, tens
		add dl, 30h
		call printNumber
	
	unitsPrinter:
		mov dl, units
		add dl, 30h
		call printNumber
	
	ret
printValue endp

invalidMedicineCheck proc
	;; if al < 1 OR al > medicine_length, GOTO invalidInput
	cmp al, 1
	jb  invalidInput
	cmp al, medicine_length
	ja  invalidInput

	;; else valid
	ret
invalidMedicineCheck endp

end main
