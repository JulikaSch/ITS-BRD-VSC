### sieb  ###

//final int n = 1000 -> wenn wir später n lesen kommt 100 raus

//byte[] sieb = new byte [n +1 ]; 0 = primzahl, 1 = keine primzahl , wir zählen von 0 bis 1000 deswegen n + 1
//sieb [0] = 1;
//sieb [1] = 1; ->0 und 1 sind keine primzahlen wir nehmen sie vorher aus der menge

// int i = 2 
// while (i * i <= n) -> solange i * i kleiner als 1000 mach weiter
// wird nur bis i * 31 laufen
//if (sieb[i] == 0)
//int j = i * i
//while (j <= n) {
	sieb [j] = 1;  // sieb an der stelle 4 = 1 also keine primzahl
	j = j + i;	
}
// i = i + 1;


## abspeichern ##

//short [] primzahlen = new short [170];  // array mit bites, 
//int k = 0 ; 
//for (int n = 2; n <= n; n = n + 1) {
	if (sieb[n]) == 0) {
		primzahlen[k] = (short) n; 
		k = k +1; 
	}
}
