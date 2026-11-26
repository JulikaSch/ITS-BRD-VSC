Testprotokoll für Taschenrechner:
INTMAX =  2147483647
INTMIN = -2147483648
                                    erwartet    bekommen
stack.c
    push:       stackoverflow 10    OF          OF
    pop:        werden nur
    peek:       indirekt aufgerufen 

operate.c
p   printhead:  auf leeren Stack    UF          UF
P   print3:     auf 2 ele           UF          UF
                auf 1 ele           UF          UF
                auf 0 ele           UF          UF
d   dubhead:    auf leehren Stack   UF          UF
r   swap2head:  auf 1 ele           UF          UF
                auf 0 ele           UF          UF

calc.c
+   stack add   auf 1 ele           UF          UF
                auf 0 ele           UF          UF
                a+b > INTMAX        Range       Range
                -a+b < INTMIN       Range       Range
-   stack sub   auf 1 ele           UF          UF
                auf 0 ele           UF          UF
                b--a> INTMAX        Range       Range
                -b-a< INTMIN        Range       Range
*   stack mul   auf 1 el            UF          UF
                auf 0 ele           UF          UF
                a*b> INTMAX         Range       Range
                a*-b< INTMIN        Range       Range
                -a*b< INTMIN        Range       Range
                -a*-b>INTMAX        Range       Range
/   stack div   auf 1 ele           UF          UF
                auf 0 ele           UF          UF
                /0                  Div0        Div0
                b=INTMIN/-1         Range       Range


