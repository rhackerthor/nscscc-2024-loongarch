    .org 0x0
    .text
    .global _start
_start:
    beq         $zero,$zero,mul
mul:
    addi.w      $t0,$zero,0x10
    addi.w      $t1,$zero,0x11
    mul.w       $t2,$t1,$t0
end:
    beq         $zero,$zero,end

