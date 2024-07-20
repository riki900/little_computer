# test of ????

    PUTS TEST_MSG:
    PUTS START_MSG:
    PUTS SPACES:

 # test with NEGATIVE_CC
    PUTS NEGATIVE_CC:
    LDI R1,-0x0001
    ???? BRANCH_NEG_CC:
    PUTS NO_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:
    BR TEST_ZERO_CC:

BRANCH_NEG_CC: NOP
    PUTS DID_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:

    # test with ZERO_CC
TEST_ZERO_CC: NOP
    PUTS ZERO_CC:
    LDI R1,0x0000
    ???? BRANCH_ZERO_CC:
    PUTS NO_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:
    BR TEST_POS_CC:
BRANCH_ZERO_CC: NOP
    PUTS DID_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:

TEST_POS_CC: NOP
    # test with POSITIVE_CC
    PUTS POSITIVE_CC:
    LDI R1,0x0001
    ???? BRANCH_POS_CC:
    PUTS NO_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:   
    BR END_TESTS:

BRANCH_POS_CC: NOP
    PUTS DID_BRANCH:
    # PUTS PASSED:
    # PUTS FAILED:

END_TESTS: NOP
    PUTS SPACES:
    PUTS END_MSG:
    HALT

# print messages 

START_MSG: DC "START"
END_MSG: DC "END"

FAILED: DC "_____FAILED"
PASSED: DC "_____PASSED"
SPACES: DC "--------------"

NEGATIVE_CC: DC "NEGATIVE_CC"
ZERO_CC: DC "ZERO_CC"
POSITIVE_CC: DC "POSITIVE_CC"

NO_BRANCH: DC "NO_BRANCH"
DID_BRANCH: DC "DID_BRANCH"

TEST_MSG: DC "TEST_????"
