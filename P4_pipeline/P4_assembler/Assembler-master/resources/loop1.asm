		addi    $6,$0,1
		addi	$7,$0,2
EQ2:	bne	$6, $7, EQ1
		add		$8,$2,$3
		mult	$6,$5
		mflo	$10
		j		END
EQ1:	addi	$7,$0,1
		bne	$6,$7, DEF
		sub		$8,$2,$3
		mult	$8,$9
		mflo	$10
		j END
DEF:	addi	$6,$0,0
		addi	$8,$0,0
		addi	$10,$0,0
END:    addi	$15, $0, 15