      OUT
      BRzp LABEL
      DIV R0, R1, LABEL1
      RET
      JSRR R0
      BRnp LABEL
      BR LABEL
      BRp LABEL
      SUBI R0, R1, 0x0001
      BRnz LABEL
      DIVI R0, R1, 0x0001
      MULI R0, R1, 0x0001
      MULR R0, R1, R2
      JSR LABEL
      DIVR R0, R1, R2
      LDR R0, R1
      BRnzp LABEL
      ADDI R0, R1, 0x0001
      SUB R0, R1, LABEL1
      SUBR R0, R1, R2
      ANDR R0, R1, R2
      JMP R0
      AND R0, R1, LABEL1
      OR R0, R1, LABEL1
      ORR R0, R1, R2
      ADD R0, R1, LABEL1
      ORI R0, R1, 0x0001
      NOTR R0, R1, R2
      NOP
      HALT
      IN
      LDI R0, 0x0003
      MUL R0, R1, LABEL1
      ADDR R0, R1, R2
      LD R0, LABEL1
      ANDI R0, R1, 0x0001
      GETC
      BRz LABEL
      PUTS LABEL
      LEA R0, LABEL1

