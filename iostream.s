B begin
welcome DEFB "Welcome to the program.\n", 0
test DEFB "Test message!\n", 0
error_readchar DEFB "Could not recognise character; try again.\n", 0
test_lowercase DEFB "You entered a lower-case character.\n", 0
test_uppercase DEFB "You entered an upper-case character.\n", 0
test_symbol DEFB "You entered a symbol-character.\n", 0
test_numeric DEFB "You entered a numeric character.\n", 0
test_enter DEFB "You entered a new line.\n", 0
    ALIGN
begin ADRL R0,welcome
SWI 3
MOV R0,#0
MOV R13, #0x0F0000
MOV R1, #0x100000
MOV R2, #0
MOV R3, #0
BL readChars
BL printString
end SWI 2

readChars STMFD R13!, {R14} ; store on stack
readChar SWI 1
CMP R0, #97
BLT notLowerCase
B maybeLowerCase
notLowerCase CMP R0,#65
BLT notUpperCaseNorLower
B maybeUpperCase
notUpperCaseNorLower CMP R0,#48
BLT notLetter
notLetter CMP R0,#32
BLT notAlphaNumericSymbolic
B maybeSymbolOrNumeric
notAlphaNumericSymbolic
CMP R0,#10
BEQ definitelyEnter
B unknown
unknown ADRL R0,error_readchar
SWI 3
B readChar
finishReading LDMFD R13!, {R14}; retrieve from stack
MOV PC,R14

maybeLowerCase CMP R0,#172
BLE definitelyLowerCase
B unknown

definitelyLowerCase BL storeChar
ADRL R0, test_lowercase
SWI 3
B readChar

maybeUpperCase CMP R0,#90
BLE definitelyUpperCase
B unknown

definitelyUpperCase BL storeChar
ADRL R0, test_uppercase
SWI 3
B readChar

maybeSymbolOrNumeric CMP R0,#47
BLE definitelySymbol
CMP R0,#57
BLE definitelyNumeric
CMP R0,#64
BLE definitelySymbol
B unknown

definitelyNumeric BL storeChar
ADRL R0, test_numeric
SWI 3
B readChar

definitelySymbol BL storeChar
ADRL R0, test_symbol
SWI 3
B readChar

definitelyEnter ADRL R0, test_enter
SWI 3
B finishReading

storeChar STMFD R13!, {R14}
ADD R2,R2,#1
STR R0, [R1, #-4]!
LDMFD R13!, {R14}
MOV PC, R14

printString STMFD R13!, {R14}
MOV R4, #4
MUL R3, R2, R4
ADD R1,R1,R3
SUB R1,R1,#4
printChar LDR R0, [R1],#-4
SWI 0
SUB R2,R2,#1
CMP R2, #0
BGT printChar
LDMFD R13!, {R14}
MOV PC, R14