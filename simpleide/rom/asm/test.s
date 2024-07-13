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
end:
    beq         $zero,$zero,end
