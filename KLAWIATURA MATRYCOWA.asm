ORG 00h 				; vektor resetu
    JMP main
    ORG 03h 			;vektor przerwania INT0
    JMP int0

main:
    SETB EA 						;interrupt enable
    SETB EX0						;interrupt enable dla INT0
    MOV P0, #01110000b 	;ustaw piny input i output
    MOV R7, #00h 				;w R7 zapisujê cyfrê podan¹ na keypadzie
    JMP $ 						;czekaj na przerwanie

int0: 																;przerwanie po wciœniêciu któregoœ przycisku
    CLR EX0 														;zablokuj przerwania z INT0
    CLR CY 														;wyczyœæ Carry
    CALL scanKeypad 										;podprogram czytaj¹cy stan keypada
    MOV P0, #01110000b 									;przywróæ port 0 do podstawowych wartoœci
    CALL waitForKeyRelease 		;czekaj na puszczenie przycisku
    CLR IE0 														;wyczyœæ flagê przerwania INT0
    SETB EX0 													;w³¹cz przerwanie INT0
    RETI


scanKeypad:
    MOV R7, #01h 														;zapisz 1 w R7, aby wynik zgadza³ siê z wciœciêtym przyciskiem
    MOV P0, #01110111b 											;podaj stan niski na pierwsz¹ kolumnê keypada
    CALL columnScan										 ;skanuj kolumnê w poszukiwaniu wciœniêtego przycisku
    JB CY, returnScanKeypad	 ;je¿eli column scan ustawi³ Carry, to znaczy, ¿e przycisk zosta³ znalezniony
    MOV P0, #01111011b									 ;podaj stan niski na drug¹ kolumnê
    CALL columnScan
    JB CY, returnScanKeypad 
    MOV P0, #01111101b									 ;podaj stan niski na trzeci¹ kolumnê
    CALL columnScan
    JB CY, returnScanKeypad
    MOV P0, #01111110b									 ;podaj stan niski na czwart¹ kolumnê
    CALL columnScan
returnScanKeypad:
    RET


columnScan:
    JNB P0.6, returnColumnScan									 ;je¿eli na danym rzêdzie pojawi³ siê stan niski, skocz
    INC R7																													 ;je¿eli nie pojawi³ siê stan niski, inkrementuj R7
    JNB P0.5, returnColumnScan
    INC R7
    JNB P0.4, returnColumnScan
    INC R7
    RET 																																	;je¿eli nie znaleziono przycisku w daniej kolumnie wróæ bez ustawiania carry
returnColumnScan:
    SETB CY																													 ;flaga keyFound. Je¿eli znaleziono przycisk, ustaw carry
    RET

waitForKeyRelease:
    JNB P3.2, waitForKeyRelease 				 ;czekaj, a¿ z wejœcia INT0 zniknie stan niski
    RET