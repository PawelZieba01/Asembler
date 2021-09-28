ORG 00h 				; vektor resetu
    JMP main
    ORG 03h 			;vektor przerwania INT0
    JMP int0

main:
    SETB EA 						;interrupt enable
    SETB EX0						;interrupt enable dla INT0
    MOV P0, #01110000b 	;ustaw piny input i output
    MOV R7, #00h 				;w R7 zapisuj� cyfr� podan� na keypadzie
    JMP $ 						;czekaj na przerwanie

int0: 																;przerwanie po wci�ni�ciu kt�rego� przycisku
    CLR EX0 														;zablokuj przerwania z INT0
    CLR CY 														;wyczy�� Carry
    CALL scanKeypad 										;podprogram czytaj�cy stan keypada
    MOV P0, #01110000b 									;przywr�� port 0 do podstawowych warto�ci
    CALL waitForKeyRelease 		;czekaj na puszczenie przycisku
    CLR IE0 														;wyczy�� flag� przerwania INT0
    SETB EX0 													;w��cz przerwanie INT0
    RETI


scanKeypad:
    MOV R7, #01h 														;zapisz 1 w R7, aby wynik zgadza� si� z wci�ci�tym przyciskiem
    MOV P0, #01110111b 											;podaj stan niski na pierwsz� kolumn� keypada
    CALL columnScan										 ;skanuj kolumn� w poszukiwaniu wci�ni�tego przycisku
    JB CY, returnScanKeypad	 ;je�eli column scan ustawi� Carry, to znaczy, �e przycisk zosta� znalezniony
    MOV P0, #01111011b									 ;podaj stan niski na drug� kolumn�
    CALL columnScan
    JB CY, returnScanKeypad 
    MOV P0, #01111101b									 ;podaj stan niski na trzeci� kolumn�
    CALL columnScan
    JB CY, returnScanKeypad
    MOV P0, #01111110b									 ;podaj stan niski na czwart� kolumn�
    CALL columnScan
returnScanKeypad:
    RET


columnScan:
    JNB P0.6, returnColumnScan									 ;je�eli na danym rz�dzie pojawi� si� stan niski, skocz
    INC R7																													 ;je�eli nie pojawi� si� stan niski, inkrementuj R7
    JNB P0.5, returnColumnScan
    INC R7
    JNB P0.4, returnColumnScan
    INC R7
    RET 																																	;je�eli nie znaleziono przycisku w daniej kolumnie wr�� bez ustawiania carry
returnColumnScan:
    SETB CY																													 ;flaga keyFound. Je�eli znaleziono przycisk, ustaw carry
    RET

waitForKeyRelease:
    JNB P3.2, waitForKeyRelease 				 ;czekaj, a� z wej�cia INT0 zniknie stan niski
    RET