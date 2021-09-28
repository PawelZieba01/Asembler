;*w rejestrze R4 przechowywany jest adres segmentu wyœwietlacza LED - NIE MODYFIKOWAÆ W PROGRAMIE (trzeba by to wrzuciæ gdzieœ do pamiêci a nie do R)
;*liczby do wyœwietlenia znajduj¹ siê w pamiêci RAM pod adresem 0x60 - 0x63
;*zakodowane cyfry BCD dla wyœwietlacza 7seg -> RAM 0x70 - 0x79
;*przerwanie od timera1 u¿ywa R0, R2 i R4

	JMP main
	
	ORG 0x001B
	JMP t1_vect		;skok do obs³ugi przerwania 

;***********************   G£ÓWNA FUNKCJA PROGRAMU   ***********************
main:
	;liczby bcd do wyœwietlenia 
	MOV 0x60, #1			;segment 4
	MOV 0x61, #7			;segment 3
	MOV 0x62, #3			;segment 2
	MOV 0x63, #5			;segment 1

	;zakodowanie adresów liczb dla wyœwietlacza
	;adresRAM | kod | liczba 
	MOV 0x70,  #0xC0		;0
	MOV 0x71,  #0xF9		;1
	MOV 0x72,  #0xA4		;2
	MOV 0x73,  #0xB0		;3
	MOV 0x74,  #0x99		;4
	MOV 0x75,  #0x92		;5
	MOV 0x76,  #0x82		;6
	MOV 0x77,  #0xF8		;7
	MOV 0x78,  #0x80		;8
	MOV 0x79,  #0x90		;9

;inicjalizacja przerwañ
	SETB EA		;w³¹czenie globalnych przerwañ
	SETB ET1	;w³¹czenie przerwania od przepe³nienia timera1
	
;inicjalizacja timera1
	SETB TR1				;w³¹czenie timera1
	MOV TMOD, #0x10	;ustawienie trybu 1

	MOV TL1, #0xF5		;za³adowanie 16-bitwego rejestru timera1 wartoœci¹ 0xE5F5
	MOV TH1, #0xE5		;..	f przerwañ = 300Hz


;***********************   G£ÓWNA PÊTLA PROGRAMU   ***********************
loop:
	NOP
	JMP loop
	


;***********************   OBS£UGA PRZERWANIA TIMERA 1   ***********************
t1_vect:
	MOV TL1, #0xF5		;za³adowanie 16-bitwego rejestru timera1 wartoœci¹ 0xE5F5
	MOV TH1, #0xE5		;..	f przerwañ = 300Hz

	;MOV P1, 0xFF		;wygaszenie akualnego segmentu LED
	SETB P0.7				;aktywowanie dekodera adresu wyœwietlacza - CS


;ZAKTUALIZOWANIE ADRESU SEGMENTU LED
	MOV B, P3						;pobranie zawartoœci portu P3
	ANL B, #11100111b			;zamaskowanie bitów z portu P3, chcemy modyfikowaæ tylko bit 3 i 4
	MOV A, R4						;pobranie adresu segmentu który ma byæ w³¹czony
	RL A								;przesuniêcie adresu o 3 bity w lewo na pozycje 3 i 4
	RL A								;..
	RL A								;..
	ORL B, A						;zaktualizowanie bitu 3 i 4 - wartoœæ portu P3
	MOV R2, B						;zapisanie nowej wartoœci portu P3 do rejestru R2


;ZAKTUALIZOWANIE LICZBY DO WYŒWIETLENIA NA AKTYWNYM SEGMENCIE LED
	MOV A, R4						;pobranie adresu aktywnego segmentu LED 
	ADD A, #0x60					;przesuniêcie adresu - liczby do wyœwietlenia -> 0x60 - 0x63 (RAM)
	MOV R0, A						;zapisanie nowego adresu do R0
	MOV A, @R0					;pobranie zawartoœci komórki o adresie z R0	 - kolejny adres -> tym razem liczby BDC 
	ADD A, #0x70					;przesuniêcie adresu - kody liczb do wyœwietlenia -> 0x70 - 0x79
	MOV R0, A						;zapisanie nowego adresu do R0
	MOV A, @R0					;pobranie zawartoœci komórki o adresie z R0	 - kod liczby od 0-9 gotowy do wystawienia na port P1
	
	MOV P3, R2					;ustawienie portu P3 - wybranie segmentu LED
	MOV P1, A						;ustawienie portu P1 - wyœwietlenie liczby w segmencie

;ZMIANA ADRESU SEGMENTU NA KOLEJNY
	INC R4							;inkrementowanie adresu segmentu - koleny segment
	CJNE R4, #4, ne1			;je¿eli adres wiêkszy od 3 to wyzeruj
	MOV R4, #0					;wyzerowanie adresu w R4
ne1:
	RETI
