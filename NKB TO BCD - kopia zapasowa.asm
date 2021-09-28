	MOV R0, #0xFF		;L
	MOV R1, #0xFF		;H
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0

	MOV R6, #16

;*********************   P�TLA KONWERUJ�CA 16-BITOW� LICZB� NKB NA BCD (16 powt�rze�)   *********************
loop:	
;sprawdzenie pierwszej i drugiej liczby BCD (rejestr R2) (je�li liczba wi�ksza od 4 to dodaj 3)
	MOV A, R2					;pobranie m�odszego bajtu s�owa 16bit
	ANL A, #0x0F				;wyczyszczenie starszej cz�ci bajtu
	MOV B, A					;zapisanie bajtu do rejestru B (tylko 4 m�odsze bity, reszta to zera)

	CLR C						;wyczyszczenie C
	SUBB A, #0x05			;odj�cie #5 od A, je�li C zostanie ustawione na '1' to liczba w m�odszej cz�ci bajtu jest mniejsza od 5
	MOV A, B					;przywr�cenie warto�ci A z przed odejmowania
	JC lt5_1					;je�eli C == 1 to przeskocz operacj� dodawania liczby 3, w przeciwnym wypadku:
	ADD A, #0x03				;dodanie #3 do A
lt5_1:
	MOV B, A					;zapisanie bajtu do rejestru B (tylko 4 m�odsze bity, reszta to zera)


	MOV A, R2					;pobranie m�odszego bajtu s�owa 16bit 
	ANL A, #0xF0				;zamaskowanie m�odszej cz�ci bajtu zerami
	SWAP A						;zamienienie po��wek bajtu miejscami
	MOV R5, A					;zapisanie bajtu do R5 (tylko 4 m�odsze bity, reszta to zera)

	CLR C						;wyczyszczenie C
	SUBB A, #0x05			;odj�cie #5 od A, je�li C zostanie ustawione na '1' to liczba w m�odszej cz�ci bajtu jest mniejsza od 5
	MOV A, R5					;przywr�cenie warto�ci A z przed odejmowania
	JC lt5_2					;je�eli C == 1 to przeskocz operacj� dodawania liczby 3, w przeciwnym wypadku:
	ADD A, #0x03				;dodanie #3 do A
lt5_2:
	SWAP A						;zamienienie po��wek bajtu miejscami (bity na swoim miejscu)
	ADD A, B					;dodanie obu po��wek bajtu (m�odsza i starsza cz��)
	
	MOV R2, A					;zapisanie sprawdzonego bajtu do R2




;sprawdzenie trzeciej i czwartej liczby BCD (tak samo jak wcze�niej tylko dla rejestru R3)
	MOV A, R3
	ANL A, #0x0F
	MOV B, A

	CLR C
	SUBB A, #0x05
	MOV A, B
	JC lt5_3
	ADD A, #0x03
lt5_3:
	MOV B, A


	MOV A, R3
	ANL A, #0xF0
	SWAP A
	MOV R5, A	

	CLR C
	SUBB A, #0x05
	MOV A, R5
	JC lt5_4	
	ADD A, #0x03
lt5_4:
	SWAP A
	ADD A, B
	
	MOV R3, A


;sprawdzenie pi�tej i sz�stej liczby BCD (tak samo jak wcze�niej tylko dla rejestru R4)
	MOV A, R4
	ANL A, #0x0F
	MOV B, A

	CLR C
	SUBB A, #0x05
	MOV A, B
	JC lt5_5
	ADD A, #0x03
lt5_5:
	MOV B, A


	MOV A, R4
	ANL A, #0xF0
	SWAP A
	MOV R5, A	

	CLR C
	SUBB A, #0x05
	MOV A, R5
	JC lt5_6
	ADD A, #0x03
lt5_6:
	SWAP A
	ADD A, B
	
	MOV R4, A


		;********************   PRZESUNI�CIE LICZBY 16bit W LEWO O JEDN� POZYCJ�   ********************
		;							   R4       R3       R2      *R1      *R0                 <-- R1 i R0 - liczba 16bit 
  		;							00001111 <- 00001111 <- 00001111 <- 00001111 <- 00001111
		;                         CY          CY          CY          CY 
		;                                                              
	CLR C			;wyczyszczenie bity C - wk�adamy '0' z prawej strony bajtu

	;przesuni�cie w lewo m�odszego bajtu
	MOV A, R0			;pobranie m�odszej cz�ci s�owa 16bit
	RLC A				;obr�t w lewo przez bit C - wk�adamy '0' od prawej strony
	MOV R0, A			;zapisanie obecnej warto�ci do R0 (m�odszy bajt s�owa) - ostatni bit (ten z lewej) jest przepisywany do C
							;w kolejnym kroku zostanie wsuni�ty od prawej strony do kolejnego bajtu 

	;przesuni�cie w lewo m�odszego bajtu
	MOV A, R1																																																																										;..
	RLC A																																																																											;..
	MOV R1, A																																																																										;..

	;przesuni�cie rejestru z liczb� 10s i 1s
	MOV A, R2																																																																											;..
	RLC A																																																																												;..
	MOV R2, A																																																																											;..

	;przesuni�cie rejestru z liczb� 1000s i 100s
	MOV A, R3																																																																											;..
	RLC A																																																																												;..
	MOV R3, A																																																																											;..

	;przesuni�cie rejestru z liczb� 100000s i 10000s
	MOV A, R4																																																																											;..
	RLC A																																																																												;..
	MOV R4, A																																																																											;..
	
	DJNZ R6, loop				;je�eli NIE przesuni�to jeszcze ca�ego s�owa (16 powt�rze�) to powt�rz procedur�
	
	

		;********************   ZAPIS LICZB BCD DO PAMI�CI RAM   ********************
	;liczba jedno�ci -> 0x60 (RAM)
	MOV A, R2
	ANL A, #0x0F				;zamaskowanie nieistotnej cz��i bajtu
	MOV 0x60, A
	;liczba dziesi�tek -> 0x61 (RAM)
	MOV A, R2
	ANL A, #0xF0				;zamaskowanie nieistotnej cz��i bajtu
	SWAP A						;zamienienie miejscami bit�w starszych i m�odszych
	MOV 0x61, A
	;liczba setek -> 0x62 (RAM)
	MOV A, R3
	ANL A, #0x0F				;..
	MOV 0x62, A
	;liczba tysi�cy -> 0x63 (RAM)
	MOV A, R3
	ANL A, #0xF0				;..
	SWAP A						;..
	MOV 0x63, A
	;liczba 10tys -> 0x64 (RAM)
	MOV A, R4
	ANL A, #0x0F				;..
	MOV 0x64, A
	;liczba 100tys -> 0x65 (RAM)
	MOV A, R4
	ANL A, #0xF0				;..
	SWAP A						;..
	MOV 0x65, A

	JMP $
