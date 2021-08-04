INCLUDE os.s
usercode
ADRL R0, printme
SVC svc_1 ;printsr
SVC svc_0 ;halt
printme DEFB "Hello World!",0
INCLUDE lcd.s
