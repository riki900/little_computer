
LDI R0, 0x0000
LDI R1, 0x0001
LDI R2, 0x0001

ORR R3, R0, R1
ORR R4, R1, R0

ORI R5, R1, 0x0000
ORI R6, R1, 0x0001

OR R7,R0, NUM:
HALT

NUM: DC 0x0000