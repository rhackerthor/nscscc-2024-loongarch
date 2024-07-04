    .org 0x0
    .text
    .global _start
_start:
  beq           $zero,$zero,main
info:
    .asciz "ABCDEFGH"
    .p2align 2
main:
    addi.w $t0,$zero,0x3
    andi   $t0,$t0,0x1
end:
    beq         $zero,$zero,end