# Par Mathieu Perron et Philippe Auclair

.data
	demanderElem: .asciiz "valeur?"
	demanderN:    .asciiz "grandeur du tableau?\n"
	nextLine:     .asciiz "\n"	

.text
.globl createArray, askGrandeurTableau, demanderN
       createArray: # cette loop cree le tableau et demande a l'utilisateur les valeurs qui le composeront 
		slt $t0, $s1, $s0     # if (index < tab.length) {t0=1} else 0
		beqz $t0, done        # t0 = 0 ? done : continue		
		sll $t0, $s1, 2       # Shift left logical : $t0 << 2 == i * 4
		add $t0, $t0, $s2     # adresse de array[i]
		
		li, $v0, 4             
		la, $a0, demanderElem  # value ?
		syscall                # print
		li, $v0, 5             # prompt
		syscall	               # get value
		add $t1, $0, $v0       # t1 = value
		sw $t1, 0($t0)	       # array[i] = value
		li, $v0, 4
		la, $a0, nextLine
		syscall                # print("\n")
		
		addi $s1, $s1, 1       # i++
		
		j createArray
	done:	
		add $t0, $0, $0 # t0 = 0
		add $t1, $0, $0 # t1 = 0
		add $s1, $0, $0 # s1 = 0
		
		jr $ra
		
	askGrandeurTableau:
		
		li $v0, 4         # print 
		la $a0, demanderN # " quelle grandeur ? "
		syscall           # execute
		li $v0, 5         # prompt 
		syscall
		#store la valeur dans un addrese 
		sw $v0, longueurTab
		#affiche message de confirmation
		li $v0, 4
		la $a0, affirmerN
		syscall
		# display la grandeur
		li $v0, 1
		lw $a0, longueurTab # print( tab.length )
 		syscall
		li $v0, 4
		la $a0, nextLine    # " \n "
		syscall
		jr $ra
		
	 # $s0 = n 
	 # $s1 = i
