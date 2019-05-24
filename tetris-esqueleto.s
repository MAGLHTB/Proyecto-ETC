# Versión incompleta del tetris 
# Sincronizada con tetris.s:r2916
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0
pieza_siguiente:
	.word	0
	.word	0
	.space	1024
caja_pieza_siguiente:
	.word	10
	.word	7
	.ascii	"----------|        ||        ||        ||        ||        |----------"
imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	
txtfin:
	.word	18
	.word	4
	.ascii	"__________________+ FIN DE PARTIDA ++ Pulse una tecla+------------------"
str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"	
str003:
	.asciiz		"Puntuacion: "
str004:
	.asciiz		"\n"	
intpuntua:
	.word 0
txtpuntua:
	.space	8
	.text	
	
imagen_dibuja_cadena:
	addi 	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0	#Dir. Imagen
	move	$s1, $a1	#X
	move	$s2, $a2	#Y
	move	$s3, $a3	#Dir. Cadena

	lb	$s4, 0($s3)
BX:	beqz 	$s4, FBX

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s4

	jal	imagen_set_pixel
	addi	$s1, $s1, 1
	addi	$s3, $s3, 1
	lb	$s4, 0($s3)
	j	BX
FBX:

	lw	$s0, 0($sp)
       	lw	$s1, 4($sp)
       	lw	$s2, 8($sp)
       	lw	$s3, 12($sp)
       	lw	$s4, 16($sp)
       	lw	$s5, 20($sp)
       	lw	$ra, 24($sp)
       	addi	$sp, $sp, 28
        jr	$ra
imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:
	addiu	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	move	$s0, $a3		# s0 = fondo
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	sb 	$s0, 0($v0)		# guardar el fondo en el pixel
		
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra

imagen_clean:
	addi 	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	# $a0 = img, $a1 = fondo
	
	move	$s0, $a0
	move	$s1, $a1
	lw	$s2, 0($s0)	#img_x
	lw	$s3, 4($s0)	#img_y
	li	$s4, 0		#x
bucy:	bge	$s4, $s3, fbucy
	li	$s5, 0		#y
bucx:   bge	$s5, $s2, fbucx
	move	$a0, $s0
	move	$a1, $s5
	move	$a2, $s4
	move	$a3, $s1
	jal	imagen_set_pixel
        addi	$s5, $s5, 1
	j	bucx
fbucx:	addi	$s4, $s4, 1
	j	bucy
fbucy:
        
        lw	$s0, 0($sp)
       	lw	$s1, 4($sp)
       	lw	$s2, 8($sp)
       	lw	$s3, 12($sp)
       	lw	$s4, 16($sp)
       	lw	$s5, 20($sp)
       	lw	$ra, 24($sp)
       	addi	$sp, $sp, 28
        jr	$ra
        
imagen_init:
	addiu	$sp, $sp, -4 
	sw	$ra, 0($sp)
	#$a0 = img, $a1 = ancho, $s2 = alto, $a3 = fondo
	
	sw	$a1, 0($a0)	# 1er elemento = x
	sw	$a2, 4($a0)	# 2o elemento = y
	move	$a1, $a3	# a1 = fondo
	jal	imagen_clean	#
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_copy:
	addi 	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	# $a0 = dst, $a1 = src
	
	move	$s0, $a0	#dst
	move	$s1, $a1	#src
	lw	$s2, 0($s1)	#img_x
	lw	$s3, 4($s1)	#img_y
	sw	$s2, 0($s0)
	sw	$s3, 4($s0)
	li	$s4, 0		#x
bucy2:	bge	$s4, $s3, fbucy2
	li	$s5, 0		#y
bucx2:  bge	$s5, $s2, fbucx2
	move	$a0, $s1	#src
	move	$a1, $s5	#x
	move	$a2, $s4	#y
	jal	imagen_get_pixel
	move	$a0, $s0	#dst
	move	$a1, $s5
	move	$a2, $s4
	move	$a3, $v0	#p
	jal	imagen_set_pixel
        addi	$s5, $s5, 1
	j	bucx2
fbucx2:	addi	$s4, $s4, 1
	j	bucy2
fbucy2:
		
        lw	$s0, 0($sp)
       	lw	$s1, 4($sp)
       	lw	$s2, 8($sp)
       	lw	$s3, 12($sp)
       	lw	$s4, 16($sp)
       	lw	$s5, 20($sp)
       	lw	$ra, 24($sp)
       	addi	$sp, $sp, 28	
        jr	$ra

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	addiu	$sp, $sp, -36	#Pila --->
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	#$a0 = dst, $a1 = src, $a2 = dst_x, $a3 = dst_y
	
	move	$s0, $a0	#dst
	move	$s1, $a1	#src
	move	$s2, $a2	#dst_x
	move	$s3, $a3	#dst_y
	li	$s4, 0
	lw	$s5, 0($s1)	#src_x
	lw	$s6, 4($s1)	#src_y
bucy1:	bge	$s4, $s6, fbucy1
	li	$s7, 0
bucx1:	bge	$s7,$s5,fbucx1
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s4
	jal	imagen_get_pixel
	beqz 	$v0, pvacio
	move	$a0, $s0
	add	$a1, $s2, $s7
	add	$a2, $s3, $s4
	move	$a3, $v0
	jal	imagen_set_pixel
pvacio:	addi	$s7,$s7,1
	j	bucx1
fbucx1:	addi	$s4,$s4,1
	j	bucy1
fbucy1:
	
	lw	$s0, 0($sp)	#Pila --->
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36	#<--- Pila
	jr	$ra

imagen_dibuja_imagen_rotada:
	addiu	$sp, $sp, -36	#Pila --->
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	#$s0 = dst; $s1 = src; $s2 = dst_x; $s3 = dst_y
	
	move	$s0, $a0	#dst
	move	$s1, $a1	#src
	move	$s2, $a2	#dst_x
	move	$s3, $a3	#dst_y
	li	$s4, 0
	lw	$s5, 0($s1)	#src_x
	lw	$s6, 4($s1)	#src_y
bucy3:	bge	$s4, $s6, fbucy3
	li	$s7, 0
bucx3:	bge	$s7,$s5,fbucx3
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s4
	jal	imagen_get_pixel
	beqz 	$v0, novacio3
	move	$a0, $s0
	add	$a1, $s2, $s6	# $a1 = dst_xn + src->alto
	subi	$a1, $a1, 1	# $a1 = $a1 - 1
	sub	$a1, $a1, $s4	# $a1 = $a1 - y
	add	$a2, $s3, $s7
	move	$a3, $v0
	jal	imagen_set_pixel
novacio3:
	addi	$s7,$s7,1
	j	bucx3
fbucx3:
	addi	$s4,$s4,1
	j	bucy3
fbucy3:
	
	lw	$s0, 0($sp)	#Pila --->
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36	#<--- Pila
	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4	#<--- PILA
	sw	$ra, 0($sp)	#PILA--->
	
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	
	lw	$ra, 0($sp)	#<--- PILA
	addiu	$sp, $sp, 4
	jr	$ra		#PILA --->
	
mostrar_marcador:
	addiu	$sp, $sp, -4	#<--- PILA
	sw	$ra, 0($sp)	#PILA--->
	
	la	$a0, pantalla
	li	$a1, 0
	li	$a2, 0
	la	$a3, str003
	jal	imagen_dibuja_cadena
	lw	$a0, intpuntua
	li	$a1, 10
	la	$a2, txtpuntua
	jal	integer_to_string
	la	$a0, pantalla
	li	$a1, 15
	li	$a2, 0
	la	$a3, txtpuntua
	jal	imagen_dibuja_cadena
	lw	$ra, 0($sp)	#<--- PILA
	addiu	$sp, $sp, 4
	jr	$ra		#PILA --->
	
integer_to_string:		# ($a0, $a1, $a2) = (n, base, buf)	
	move    $t0, $a2		# char *p = buff
	beqz 	$a0,B3_cero
	# for (int i = n; i > 0; i = i / base) {
        abs	$t1, $a0		# int i = n
B3_3:   blez	$t1, B3_Neg		# si i <= 0 salta el bucle
	div	$t1, $a1		# i / base
	mflo	$t1			# i = i / base
	mfhi	$t2			# d = i % base
	addiu	$t2, $t2, '0'		# d + '0'
	sb	$t2, 0($t0)		# *p = $t2 
	addiu	$t0, $t0, 1		# ++p
	j	B3_3			# sigue el bucle
        # }  
B3_Neg: bgez    $a0, B3_Inv
        li 	$t6, '-'		
     	sb 	$t6, 0($t0)
     	addiu	$t0, $t0, 1
B3_cero:
	li 	$t1,'0'
	sb 	$t1,0($t0)
	addi 	$t0,$t0,1
	j  	B3_7	
	# $t1=i; $t2=j;$to=p; $t4=aux
B3_Inv:	move 	$t1,$a2  	#i=buf
	subi   	$t2,$t0, 1 	#j=p-1;
Bucle3:	sub 	$t3,$t2,$t1
	blez	$t3, B3_7
	lb 	$t4, 0($t1)	#aux=*i;
	lb 	$t5, 0($t2)	# *i=*j;
	sb	$t5, 0($t1)
	sb	$t4, 0($t2)	#*j=aux;
	addiu	$t1, $t1, 1	#i++;
	subiu 	$t2, $t2, 1	#j--;
	j Bucle3	
B3_7:	sb	$zero, 0($t0)		# *p = '\0'
B3_10:	jr	$ra

eliminar_linea:
	addiu	$sp, $sp, -24	#Pila --->
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	
	move	$s0, $a0	#Campo
	move	$s1, $a1	# Y a borrar
	lw	$s2, 0($a0)	# X de la pantalla
	li	$s3, 0
ely:	ble	$s1, $s3, fely	#Bucle Y
	li	$s4, 0
elx:	bgt	$s4, $s2, felx	#Bucle X
	##
	move	$a0, $s0
	move	$a1, $s4
	subi	$a2, $s1, 1
	jal	imagen_get_pixel
	move	$a0, $s0
	move	$a1, $s4
	move	$a2, $s1
	move	$a3, $v0
	jal	imagen_set_pixel
	##
	addi	$s4, $s4, 1
	j	elx
felx:	subi	$s1, $s1, 1
	j	ely
fely:	
	lw	$s0, 0($sp)	#Pila --->
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24	#<--- Pila
	jr	$ra

completar_linea:
	addiu	$sp, $sp, -32	#Pila --->
	sw	$ra, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	
	move	$s0, $a0
	lw	$s1, 0($s0)	#X
	lw	$s2, 4($s0)	#Y
	li	$s4, 0		#contador y
BUCLY:	bge	$s4, $s2,FBUCLY	#Bucle Y
	li	$s5, 0		#contador x
	li	$s6, 0		# contador de #
BUCLX:	bge	$s5, $s1,FBUCLX	#Bucle X
	move	$a0, $s0
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel
	bne	$v0, '#', noalm
	addi	$s6, $s6, 1
noalm:	addi	$s5, $s5, 1
	j	BUCLX
FBUCLX:	bne	$s6, 14, no10
	lw	$t0, intpuntua
	addi	$t0, $t0, 10
	sw	$t0, intpuntua
	la	$a0, campo
	move	$a1, $s4
	jal	eliminar_linea
no10:	addi	$s4, $s4, 1
	j	BUCLY
FBUCLY:
	lw	$s0, 0($sp)	#Pila --->
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32	#<--- Pila
	jr	$ra
		
actualizar_pantalla:
	addiu	$sp, $sp, -12	#<--- PILA
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)	#PILA --->
	
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' '
	## COMPLETAR LINEA
	la	$a0, campo
	jal	completar_linea
	## FIN COMPLETAR LINEA
	### PUNTUACION
	jal	mostrar_marcador
	#Mostrar recuadro pieza siguiente
	la	$a0,pantalla
	la	$a1,caja_pieza_siguiente
	li	$a2,18
	li	$a3,0
	jal	imagen_dibuja_imagen
	la	$a0, pantalla
	la	$a1,pieza_siguiente
	li	$a2,22
	li	$a3,2
	jal	imagen_dibuja_imagen
	
		
	### PUNTUACION
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	
	lw	$s1, 0($sp)	#<--- PILA
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra		#PILA --->

nueva_pieza_actual:
	addiu	$sp, $sp, -4	#<--- PILA
	sw	$ra, 0($sp)	#PILA --->
	
	jal	pieza_aleatoria		#Salta a pieza aleatoria
	la	$a0, pieza_actual	# $a0 = pieza_actual 
	move	$a1, $v0		# $a1 = nueva pieza aleatoria
	jal	imagen_copy
	la	$t0, pieza_actual_x
	la	$t1, pieza_actual_y
	li	$t2, 8
	li	$t3, 0
	sw	$t2, 0($t0)
	sw	$t3, 0($t1)
	
	
	
	lw	$ra, 0($sp)	#<--- PILA
	addiu	$sp, $sp, 4
	jr	$ra		#PILA --->
	
nueva_pieza_siguiente:
	addiu	$sp,$sp,-20
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	jal 	pieza_aleatoria
	la	$s0,pieza_siguiente
	move	$a0,$s0
	move	$a1,$v0
	jal	imagen_copy
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addiu	$sp,$sp,20
	jr	$ra
cambiar_pieza_siguiente_actual:
	addiu	$sp,$sp,-12
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	
	
	la	$a0,pieza_actual
	la	$a1,pieza_siguiente
	jal	imagen_copy
	li	$s0,8
	li	$s1,0
	sw	$s0,pieza_actual_x
	sw	$s1,pieza_actual_y
	jal	nueva_pieza_siguiente
	
	
	
	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)

	addiu	$sp,$sp,12
	jr	$ra
			
probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32	#<--- PILA
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#PILA --->
	
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true

B12_13:	lw	$s0, 0($sp)	#<--- PILA
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra		#PILA --->

intentar_movimiento:
	addiu	$sp, $sp, -12	#Pila --->
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	# $s0 = x, $s1 = y
	
	move	$s0, $a0	#x
	move	$s1, $a1	#y
	la	$a0, pieza_actual
	move	$a1, $s0
	move	$a2, $s1
	jal	probar_pieza
	bne	$v0, 1, nouno
	la	$t1, pieza_actual_x
	la	$t2, pieza_actual_y
	sw	$s0, 0($t1)
	sw	$s1, 0($t2)
	li	$v0, 1
	j	fin_im
nouno:	li	$v0, 0
fin_im:
	
	lw	$s0, 0($sp)	#<--- PILA
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra		#PILA --->
	
fin_partida_arriba:
	addiu	$sp, $sp, -4	#<--- PILA
	sw	$ra, 0($sp)	#PILA --->
	
	la	$a0, pantalla
	la	$a1, txtfin
	li	$a2, 0
	li	$a3, 10
	jal	imagen_dibuja_imagen
	jal	clear_screen
	la	$a0, pantalla
	jal	imagen_print
	jal	read_character
	jal	main
	
	lw	$ra, 0($sp)	#<--- PILA
	addiu	$sp, $sp, 4	
	jr	$ra		#PILA --->

bajar_pieza_actual:
	addiu	$sp, $sp, -4	#<--- PILA
	sw	$ra, 0($sp)	#PILA --->
	
	lw	$a0, pieza_actual_x
	lw	$a1, pieza_actual_y
	addi	$a1, $a1, 1
	jal	intentar_movimiento
	beq	$v0, 1, nocum
	## Si y = 0
	lw	$t0, pieza_actual_y
	bnez 	$t0, noescero
	jal	fin_partida_arriba
	#Fin comprobacion
noescero:	
	la	$a0, campo
	la	$a1, pieza_actual
	lw	$a2, pieza_actual_x
	lw	$a3, pieza_actual_y
	jal	imagen_dibuja_imagen
	
	#
	jal	cambiar_pieza_siguiente_actual
	#
	
	## SUMAR 1 Puntuación
	
	lw	$t1, intpuntua
	addi	$t1, $t1, 1
	sw	$t1, intpuntua
	
	## FIN SUMAR 1 Puntucion
nocum:		
	
	lw	$ra, 0($sp)	#<--- PILA
	addiu	$sp, $sp, 4	
	jr	$ra		#PILA --->

intentar_rotar_pieza_actual:
	addiu	$sp, $sp, -20	#Pila --->
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	#<--- Pila Los que utilice
	
	la	$s0, imagen_auxiliar	# *PiezaRotada
	la	$s1, pieza_actual
	lw	$s2, 0($s1)	#x de pieza actual (ancho)
	lw	$s3, 4($s1)	#Y de pieza actual (alto)
	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s2
	li	$a3, 0
	jal	imagen_init
	move	$a0, $s0
	move	$a1, $s1
	li	$a2, 0
	li	$a3, 0
	jal 	imagen_dibuja_imagen_rotada
	move	$a0, $s0
	lw	$a1, pieza_actual_x
	lw	$a2, pieza_actual_y
	jal	probar_pieza
	beqz	$v0, nocum2
	move	$a0, $s1
	move	$a1, $s0
	jal	imagen_copy
nocum2:

	lw	$s0, 0($sp)	#<--- PILA
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20	
	jr	$ra		#PILA --->

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 40			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B21_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B21_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B21_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B21_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	##PUntuacion = 0
	li	$t0, 0
	sw	$t0, intpuntua
	
	la	$a0, pantalla
	li	$a1, 28			#aumentamos a 28 el ancho para que quepa el recuadro con pieza_siguiente
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	jal	nueva_pieza_siguiente
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B22_2
        # while (!acabar_partida) { 
B22_2:	lbu	$t1, acabar_partida
	bnez	$t1, B22_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B22_2	# if (transcurrido < pausa) siguiente iteración
B22_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B22_2			# siguiente iteración
       	# } 
B22_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B23_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B23_1		# if (opc == '2') salir
	bne	$v0, '1', B23_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B23_2
B23_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B23_2
B23_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B23_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
