.data
ultimaPozMem: .long 0
nrOP: .long 0
codOP: .long 0
format: .asciz "%d"                         
nrF: .long 0
nrTotalF: .long 0
des: .space 4
Size: .space 4
len: .long 1023
pozP: .long 0
pozU: .long 0
formatA_D_D: .asciz "%d: (%d, %d)\n"
formatGET: .asciz "(%d, %d)\n"
a: .long 0
b: .long 0
c: .long 0
e: .long 0
t: .long 0
v: .space 8193  # spatiu pentru 1024  de blocuri

.text
Add:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %esi
    push %edi

    xor %edx, %edx         # pregatim calculul
    movl 12(%ebp),%eax    # Size 
    movl $8,%ebx          # impartim la 8
    addl $7,%eax          # aproximam
    idiv %ebx              # eax = nr blocuri necesare
    lea v, %edi

    cmp $2,%eax            # daca eax < 2 nu se poate aloca
    jl cazulO           

    xor %ebx,%ebx         # contor pt nr blocuri
    xor %ecx, %ecx         # index
    subl $1, %eax           # eax = nr blocuri -1 
    jmp cautare_spatiu

cautare_spatiu:
    cmp len, %ecx             # Daca am parcurs tot vectorul ne oprim
    jg cazulO                 # returnam 0,0

    cmpl $0, (%edi,%ecx,4)  # daca elementul curent este nul
    jne nextADD

ifvECXisO:
    addl $1, %ebx             # contorul nr bloc este incrementat
    cmp %eax,%ebx             # decidem daca am gasit un interval liber
    jg alocare
         
    addl $1,%ecx
    jmp cautare_spatiu
nextADD:
    xor %ebx,%ebx             # daca nu este liber resetam contorul  
    addl $1,%ecx
    jmp cautare_spatiu

cazulO:
    movl $0,%eax          
    movl $0,%edx

    pop %edi
    pop %esi
    pop %ebx
    mov %ebp ,%esp
    pop %ebp

    ret

alocare:
    movl %ecx, %esi        # salvam ultima poziite in esi
    movl %esi, %ebx        
    subl %eax, %ebx        # ebx = esi - eax

alocare_loop:
    cmp %esi , %ebx
    jg iesire_add_succes               # daca am terminat alocarea 

    movl 8(%ebp), %edx                 # edx = valoarea descriptorului
    movl %edx,(%edi,%ebx,4)         # v[ebx] = edx
    addl $1, %ebx
    jmp alocare_loop

iesire_add_succes:
    subl %eax, %ebx              
    movl %ebx, %eax             #eax=ebx-nrbloc-1
    subl $1, %eax                #prima pozitie
    movl %esi, %edx             #ultima pozitie
    xor %ecx,%ecx

    

   
iesireA:
    pop %edi
    pop %esi
    pop %ebx
    mov %ebp, %esp
    pop %ebp

    ret

get:
    push %ebp
    mov %esp ,%ebp
    push %ebx
    push %edi
    push %esi
   
    lea v,%edi
    mov 8(%ebp),%eax   #des = eax
    mov $0,%ecx        #index
    mov $0,%edx        #contor aparitii
cautare_get:
    cmp len,%ecx
    jg if_get

    cmpl %eax,(%edi,%ecx,4)
    je gasit_get
    
    add $1,%ecx
    jmp cautare_get
gasit_get:
   addl $1,%edx          #contor aparitii
   movl %ecx,%ebx        #salvam ultima pozitie
   addl $1,%ecx
   jmp cautare_get

if_get:
   cmpl $0,%edx
   je iesire_O_get
   
   mov %ebx,%eax          #eax =ebx
   subl %edx, %eax        #eax-= edx
   addl $1,%eax
   mov %ebx,%edx
  
   pop %esi
   pop %edi
   pop %ebx
   mov %ebp,%esp
   pop %ebp
  
   ret

iesire_O_get:
    xor %eax,%eax
    xor %edx,%edx
    
    pop %esi
    pop %edi
    pop %ebx
    mov %ebp,%esp
    pop %ebp
   
    ret   
delete:
    push %ebp
    mov %esp, %ebp
    
    push %edi
    lea v, %edi

    movl 8(%ebp), %eax      #eax=descriptorul sters

    mov $0,%ecx             #index   

cautare_del:
    cmpl len,%ecx
    jg iesire_del

    cmpl %eax,(%edi,%ecx,4)
    je transformO
   
    addl $1,%ecx
    jmp cautare_del

transformO:
    movl $0,(%edi,%ecx,4)
    addl $1,%ecx
    jmp cautare_del

iesire_del:
    pop %edi
    mov %ebp,%esp
    pop %ebp

    ret   
    
.global main
main:
    
pushl $nrOP
pushl $format                   #citim nr de operatii ce vor fi efectuate
call scanf
add $8,%esp

mov $0,%esi                     #contor pt nr de op
main_loop:
    cmp nrOP,%esi
    je exit_program
    
    pushl $codOP
    pushl $format               #citim codul operatiei 1,2,3,4
    call scanf
    add $8,%esp
   
    mov codOP,%edx
    
    cmp $1,%edx
    je mainADD

    cmp $2,%edx
    je mainGET
   
    cmp $3,%edx
    je mainDEL

    cmp $4,%edx
    je mainDEFRAG
   
    jmp exit_program 

mainADD:
    addl $1,%esi
    pushl $nrF
    push $format
    call scanf             # Citim nr de fisiere
    add $8, %esp

    movl $0, %ebx          # ebx va fi index
    
loop_add_fisier:
    cmpl nrF, %ebx          
    je main_loop 

    pushl $des
    push $format           # Citim id-ul   
    call scanf              
    add $8, %esp

    pushl $Size     
    push $format           # Citim marimea descriptorului
    call scanf              
    add $8, %esp

    movl des, %eax
    movl %eax, a            
    movl Size, %edx
    movl %edx , b

    pushl b
    pushl a
    call Add                
    add $8, %esp

    movl %eax, pozP         # Pozitia inceput
    movl %edx, pozU         # Ultima pozitie
    
    pushl %esi
    pushl %ebx
    pushl pozU
    pushl pozP
    pushl a
    push $formatA_D_D
    call printf             
    addl $24, %esp

    push $0
    call fflush
    add $4,%esp   

    addl $1, %ebx           
    jmp loop_add_fisier      

mainGET:
   addl $1,%esi

   pushl $c
   pushl $format            # citim id ul descriptorului pe care il cautam
   call  scanf
   add $8,%esp

   pushl c
   call get
   add $4,%esp

   mov %eax,pozP
   mov %edx,pozU
   
   pushl %esi
   pushl pozU
   pushl pozP
   pushl $formatGET
   call printf
   add $16,%esp

   push $0
   call fflush
   add $4,%esp
  
   jmp main_loop

mainDEL:

   addl $1,%esi

   pushl $e
   pushl $format            # citim id ul descriptorului care va fi sters
   call scanf 
   add $8,%esp

   pushl e
   call delete
   add $4,%esp

memorie:
   lea v,%edi
   movl $0,%ecx
   
for_afisare:
   cmp len, %ecx                              
   jg main_loop
   
   cmp $0,(%edi,%ecx,4)                       # daca este diferit de 0 
   jne gasit_nr
   
   addl $1,%ecx
  
   jmp for_afisare

gasit_nr:    
   movl $1,%ebx                              # contor blocuri
   movl (%edi,%ecx,4),%eax                   # eax = v[ecx]  
   movl %ecx, %edx
                                             # edx = pozitia de inceput
while_del:
    cmp len,%ecx
  
    jle next_step

    jmp afisare_memorie
next_step:                                   # while(ecx<255 and v[ecx]==des)
   cmpl %eax,(%edi,%ecx,4)
   je proces
   jmp afisare_memorie 
proces:
   addl $1,%ecx
   addl $1,%ebx
   jmp while_del
     
afisare_memorie:

   movl %ecx, %edx
   subl %ebx,%edx

   addl $1,%edx

  # cmpl $0,%edx                         #edx
  # je adauga
# adauga:
  # addl $1,%edx
    
   movl %ecx, ultimaPozMem
   subl $1, ultimaPozMem

   cmpl ultimaPozMem,%edx
   je script

   afisare_script:

   pushl %ecx
   pushl ultimaPozMem                                                 
   pushl %edx
   pushl %eax
   push $formatA_D_D
   call printf
   add $16,%esp
   
   push $0
   call fflush
   add $4,%esp

   popl %ecx
   
   subl $1,%ecx
   addl $1,%ecx

jmp for_afisare

script:
  addl $1,ultimaPozMem
  jmp afisare_script

afisare_vector:

  lea v,%edi 
  movl $0,%ecx
  
  for_cout:
   
   cmp len,%ecx
   jg exit_program

   movl (%edi,%ecx,4),%eax

   pushl %ecx
   pushl %eax
   pushl $format
   call printf
   add $8,%esp
   
   push $0
   call fflush
   add $4,%esp

   pop %ecx
    
     addl $1,%ecx 
    jmp for_cout

mainDEFRAG:
    addl $1,%esi
    movl $0,%ecx       # indexul curent
    lea v,%edi         
    movl $0,%edx       # indexul pe caae

forDEFRAG:
    cmpl len,%ecx      
    jg clearDEFRAG

    movl (%edi,%ecx,4), %eax 
    cmpl $0,%eax       
    je nextDEFRAG           

    movl %eax,(%edi,%edx,4)  
    addl $1, %edx      

nextDEFRAG:
    addl $1, %ecx       # daca e nul trecem la urmatoarea pozitie
    jmp forDEFRAG       

clearDEFRAG:
    cmpl len , %edx     
    jg memorie         

    movl $0, (%edi,%edx,4)  # Write zero at the current write index
    addl $1, %edx       # Increment write index
    jmp clearDEFRAG      # Repeat for remaining positions

exit_program:

    push $0
    call fflush
    add $4 , %esp

    mov $1,%eax
    mov $0,%ebx
    int $0x80