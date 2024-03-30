/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "David McColl"  
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    /* initialize output values */
    LDR r2,=0   // default to no error
    LDR r3,=rng_Error
    STR r2,[r3]
    
    LDR r3,=a_Multiplicand
    STR r0,[r3]
    LDR r3,=a_Sign
    STR r2,[r3]
    LDR r3,=a_Abs
    STR r2,[r3]
    
    LDR r3,=b_Multiplier
    STR r1,[r3]
    LDR r3,=b_Sign
    STR r2,[r3]
    LDR r3,=b_Abs
    STR r2,[r3]

    LDR r3,=prod_Is_Neg
    STR r2,[r3]
    LDR r3,=init_Product
    STR r2,[r3]
    LDR r3,=final_Product
    STR r2,[r3]
    
    /* check range of both values >MAX16 | <MIN16 */
    .EQU MAX16, 0x00007FFF
    .EQU MIN16, 0xFFFF8000
    LDR r2,=MAX16
    CMP r0,r2
    BGT range_error
    CMP r1,r2
    BGT range_error
    LDR r2,=MIN16
    CMP r0,r2
    BLT range_error
    CMP r1,r2
    BLT range_error

    /* save signs & abs of both values & set prod_Is_Neg*/
    LDR r4,=0          // init neg sign counter = 0
    /* process multi-and in R0 */
    mov r2,r0, LSR 31  // extract sign bit
    LDR r3,=a_Sign
    STR r2,[r3]        // save sign bit
    CMP r2,1           // if signbit==1
    NEGEQ r0,r0        //     make abs value
    ADDEQ r4,r4,1      //     inc neg count
    LDR r3,=a_Abs
    STR r0,[r3]        // save abs value

    /* process multi-er in R1 */
    mov r2,r1, LSR 31  // extract sign bit
    LDR r3,=b_Sign
    STR r2,[r3]        // save sign bit
    CMP r2,1           // if signbit==1
    NEGEQ r1,r1        //     make abs value
    ADDEQ r4,r4,1      //     inc neg count
    LDR r3,=b_Abs
    STR r1,[r3]        // save abs value
    
    AND r4,r4,1        // get LSB of neg counter
    LDR r3,=prod_Is_Neg
    STR r4,[r3]        // save prod_Is_Neg flag

    /* load abs values */
    LDR R0,=a_Abs
    LDR r0,[r0]
    ldr r1,=b_Abs
    ldr r1,[r1]
    /* check for zero values */
    CMP R0,0
    BEQ zero_return
    CMP R1,0
    BEQ zero_return
    
    /* do the shift&add multiply  R0 * R1 -> R3 */
    MOV r3,0        /* initialize product accumulator */
1:  TST R0,1        /* Z=1 if lobit of shifted A clear */
    ADDNE r3,r3,r1  /* if Z==0 add copy of shifted B into accum  */
    LSL  R1,R1,1    /* double B  */
    LSRS R0,R0,1    /* halve A */
    BNE 1b          /* loop if A not yet zero */
    ldr r2,=init_Product
    STR r3,[r2]     /* store result in init_product */
    
    /* check prod_Is_Neg --> final_Product */
    ldr r1,=prod_Is_Neg
    ldr r1,[r1]
    CMP r1,1
    NEGEQ r3,r3
    ldr r2,=final_Product
    STR r3,[r2]
    b set_return

range_error:
    mov r2,1
    LDR r3,=rng_Error
    STR r2,[r3]
    b set_return
    
zero_return:
    MOV r2,0  /* always set prod_Is_Neg=0 */
    LDR R3,=prod_Is_Neg
    STR R2,[R3]
    /* fall thru */
set_return:
    LDR r0,=final_Product  /* retrieve return value */
    LDR r0,[r0]
    /*** STUDENTS: Place your code ABOVE this line!!! **************/
done:    
screen_shot:
    pop {r4-r11,LR}
    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




