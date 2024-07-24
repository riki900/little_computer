# fibonacci sequence

    # loop limit
    LDI R4,0x0004

    # initial fibonacci numbers
    LDI R1,0x0000
    LDI R2,0x0001

LOOP: NOP
    ADDR R3, R1, R2
    LDR R1, R2
    LDR R2, R3
    SUBI R4, R4, 0x0001
    BRp LOOP:
    HALT