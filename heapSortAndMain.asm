# par Mathieu Perron et Philippe Auclair

.data 
	affirmerN: .asciiz "le tableau contiendra ce nombre d'elements : "
	longueurTab: .word 4
	backto: .asciiz "backtomain"
.text 
.globl longueurTab, affirmerN
	# s0 : la longueur du tab
	# s2 : le tableau
	main:
		jal askGrandeurTableau # quelle grandeur ?
		li $v0, 4
		la $a0, demanderN
		syscall	 	       # print(" quelle grandeur ")
		lui  $s2, 0x1004       # base = 0x1004000	 
		lw $s0, longueurTab    # s0 = tab.length
		jal createArray        # quelles valeurs ?
		jal sort               # appel la fonction de tri sort() 
		li $v0, 10             # end
		syscall
		
	 
	sort:

	 	subi $sp, $sp, 4    # alloue l'espace pour ra
	 	sw   $ra,($sp)      # store  $ra dans $sp
	 	
	 	lw   $s0, longueurTab 
	 	subi $s0, $s0, 1    # n = n-1 
		subi $s1, $s0, 1    # i = n-1
		
		srl  $s1, $s1, 1    # i = i/2
	forSort:
		sge  $t0, $s1, 0    # si s1 >= 0 alors t0 = 1 sinon 0
		beqz $t0, whileSort # si $t0 == 0 on va a whileSort
		
		add  $a1, $0, $s1   # argument 1 = i
		add  $a2, $0, $s0   # argument 2 = n
		jal  fixHeap	    # fixHeap(i,n)
		
		subi $s1, $s1, 1    # i-- 
		j    forSort
	whileSort:
		sgt  $t0, $s0, 0    # si s0(i) > 0 alors $t0 = 1 sinon t0 = 0
		beqz $t0, done2      # si t0 == 0 on va a done
		
		# on initialise nos arguments pour swap( 0, n)
		li  $a1, 0          # a1 = 0
		add $a2,$0,$s0      # a2 = n 
		jal swap            # swap ( a1 , a2 ) // ( 0, n )
		
		subi $s0,$s0, 1     # n--
		li   $a1,  0
		add  $a2, $0, $s0
		jal  fixHeap        # fixHeap ( 0, n )
		
		j whileSort
	done2:
		lw   $ra, ($sp)     # on retourne chercher notre ancien $ra
		addi $sp, $sp, 4    # on libere l'espace
		jr   $ra	    # back to main
	
	fixHeap: # $s6 = index
		 # $s7 = rootValue 
		 # $s3 = more 
		 # $s4 = leftChildIndex ( childIndex c'est melangeant ) 
		 # $s5 = rightChildIndex 

		 subi $sp, $sp, 4   # on alloue l'espace pour stock ra
		 sw   $ra, ($sp)    # stock $ra dans $sp
		 
		 add  $s6,$0, $a1   # index = rootIndex
		 
		 sll  $t0, $s6, 2    # index * 4
		 add  $t0, $t0, $s2  # t0 = addresse du tableau
		 lw   $s7, 0($t0)     # rootValue = array[index] // s7 = array[s6]
	    whileFixHeap:
	    	 # on va appeler getLeftChild donc on initie l'arg1 a index
	    	 add  $a1, $0, $s6      # a1 = index
		 jal  getLeftChildIndex # getLeftChildIndex()
		 add  $s4, $0, $v1          # leftChildIndex = getLeftChildIndex(index)
		if1:
		  sle  $t0, $s4, $a2    # si leftChildIndex <= lastIndex ? s4 <= a2 then t0 = 1 else 0 
		  beqz $t0, done3       # si t0 == 0 on va a done3
		  
		  # on va appeler getRightChild donc on initie l'arg1 a l'index
		  add $a1, $0, $s6       # a1 = index
		  jal getRightChildIndex # getRightChildIndex(index)
		  add $s5, $0, $v1       # rightChildIndex = getRightChildIndex(index)
		 if2:
	            sle $t0, $s5, $a2      # si rightChildIndex <= lastIndex t0 = 1 
		    # on va chercher les valeurs de a[rightChildIndex] & a[leftChildIndex
		    sll $t1, $s5, 2
		    add $t1, $t1, $s2
		    lw  $t1, 0($t1)        # t1 = a[rightChildIndex]
		  
		    sll $t2, $s4, 2
		    add $t2, $t2, $s2
		    lw  $t2, 0($t2)        # t2 = a[leftChildIndex] // seulement a[childIndex] dans le code
		  
		    sgt $t1, $t1, $t2      # si a[rightChildIndex] > a[leftChildIndex] t1 = 1 et 0 sinon
		    # on doit trouver le moyen que si t0 ou t1 sont faux on arrete
		    and  $t0, $t0, $t1  # si t0 = t0 && t1  comme ca si un des deux == 0 on sait qu'on a pas nos 2 conditions respectees
		    beqz $t0, if3       # si un des deux est zero on va direct a if3 ( on saute childIndex = rightChildIndex )
		    
		    # le if2 est reussi donc leftchildIndex = rightChildIndex
		    add  $s4, $0, $s5
		    
		   if3:  
		      sll $t0, $s4, 2
		      add $t0, $t0, $s2
		      lw $t0, 0($t0)
		      sgt $t1, $t0, $s7   # si array[leftChildIndex] > rootValue
		      beqz $t1, done3     # else => done3
		      
		      #if reussi donc a[index] = a[leftChildIndex]
		      sll $t2, $s6, 2    # index*4
		      add $t2, $t2, $s2  # t0 = addresseDeIndexDuArray
		      sw  $t0, 0($t2)    # a[index] = a[leftChildIndex]
		      
		      add $s6, $0, $s4  # index = leftChildIndex   
		
		      j whileFixHeap # on continue la boucle while
	    # comme les else de java font juste dire a prochain while de terminer on peut mettre
	    # directement que les done terminent la boucle while et que ca continue sinon
	    # ainsi on se sauve d'une evaluation et d'un label inutile
	    done3:
	           # preparation pour retour
	           lw   $ra, ($sp)     # on load le $ra qu'on a store dans sp 
	       	   addi $sp, $sp, 4   # procedure habituelle
	       	   # derniere operation : a[index] = rootValue // a[index($s6)] = rootValue($s7)
	       	   sll $t0, $s6, 2  
	       	   add $t0, $t0, $s2
	       	   sw  $s7, 0($t0)
	       	   # retour
	       	   jr $ra
       swap:	#s2 = base de mon Array
		sll $a1, $a1, 2  # int temp = a[i]
		add $a1, $a1, $s2 
		lw  $t7, 0($a1) # temp0 = a[i] 
		
		sll $a2, $a2, 2
		add $a2, $a2, $s2 
		lw  $t4, 0($a2) # temp1 = a[j]
		
		sw $t4, 0($a1) # a[i] = a[j]
		sw $t7, 0($a2) # a[j] = temp
		jr $ra
		
	getLeftChildIndex: # retourne 2*index+1 
	    	sll $t6, $a1, 1
	    	add $v1, $t6, 1
	    	jr $ra
	    		
	getRightChildIndex: # retourne 2*index+2 
	    	sll $t5, $a1, 1
	    	add $v1, $t5, 2
	    	jr $ra
	 
	       	   
	       	   
