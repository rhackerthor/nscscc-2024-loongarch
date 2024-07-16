    .org 0x0
    .text
    .global _start
_start:
    beq         $zero,$zero,WRITESERIAL

info:
    .asciz "Fib Finish."

    .p2align 2
feed:
    .asciz "All PASS!"

    .p2align 2
WRITESERIAL:
    lu12i.w     $s0,-0x40300    # s0 = 0xbfd00000
    la.local    $s1,info
    ld.b        $a0,$s1,0x0
loop1:
    addi.w      $s1,$s1,0x1
.TESTW:
    ld.b        $t0,$s0,0x3fc
    andi        $t0,$t0,0x001
    beq         $t0,$zero,.TESTW
    st.b        $a0,$s0,0x3F8
    ld.b        $a0,$s1,0x0
    bne         $a0,$zero,loop1

READSERIAL:
    # lui       $  s0,-0x40300
.TESTR:
    ld.b        $t0,$s0,0x3fc
    andi        $t0,$t0,0x002
    beq         $t0,$zero,.TESTR
    ld.b        $a0,$s0,0x3F8
    addi.w      $t0,$zero,0x54  # char 'T'
    bne         $a0,$t0,READSERIAL
FEEDBACK:
    lu12i.w     $s0,-0x40300    # s0 = 0xbfd00000
    la.local    $s1,feed
    ld.b        $a0,$s1,0x0
loop2:
    addi.w      $s1,$s1,0x1
.TEST:
    ld.b        $t0,$s0,0x3fc
    andi        $t0,$t0,0x001
    beq         $t0,$zero,.TEST
    st.b        $a0,$s0,0x3F8
    ld.b        $a0,$s1,0x0
    bne         $a0,$zero,loop2

end:
    beq         $zero,$zero,end
