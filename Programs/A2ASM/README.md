Anw01 
ldr     R0,=VariableA
    schreibt die (4 Byte = 32 Bit große) Adresse der VariableA, also wo die VariableA im Speicher liegt, in das Register R0.
    (kein Speicherzugriff?)
    -> R0 = 0x2000000c

Anw02
ldrb    R2,[R0]
    lese die Adresse, die in Register 0 steht und gehe dort hin (-> Speicherzugriff) und lade 1 Byte davon in Register 2.
    -> R2 = 0xef

    weil im little endian mode steht das least significant Byte des Halbwortes "beef" auf der kleinsten Adresse liegt. Und ldrb ließt nur 1 Byte, aber "beef" ist 2 Byte lang.

An03
ldrb    R3,[R0,#1]
    lese die Adresse, die in Register 0 steht und gehe an diese Adresse, aber um ein Offset von 1 Byte weiter und lade 1 Byte in Register 3.
    -> R3 = 0xbe

Anw04
lsl     R2, #8 
    Bit-Shift nach links um 8 Bit = 1 Byte. Füllt mit 0-en auf. Verschiebt also um 2 Hex-Stellen nach links.
    -> R2 = 0xef00

Anw05
orr     R2, R3
    bitweises logisches Oder der Inhalte von Register 2 und 3 und schreibt das Ergebnis in R2.
    -> R2 = 0xefbe

Anw06
strh    R2,[R0]
    lese die Adresse, die in Register 0 steht und gehe an diese Adresse im Speicher und speichere dort den (2 Byte großen) Inhalt aus Register 2. Speichert das geswappte beef in VariableA. Wegen little endian mode steht das LSB auf der kleinsten Adresse (Byte Swapping)
    -> 0x2000000c = be ef 
