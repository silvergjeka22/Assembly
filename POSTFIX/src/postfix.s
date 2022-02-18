#########################################################
.section .data              #sezione data

neg:                        #1 => numero negativo, 0 => numero positivo
   .int 0
   
operazione:                 #1 => operazione avvenuta, 0 => 0perazione non avvenuta
   .int 0

error:                      #stringa invalid
    .ascii "Invalid"

.section .text              #sezione text
    .global postfix
#########################################################
postfix:
      mov 4(%esp),%esi       #salvo nel registro %esi il puntatore alla stringa in input
      mov 8(%esp),%edi       #salvo nel registro %esi il puntatore alla stringa in onput
    
      pushl %eax             #salvo lo stato dei registri 
      pushl %ebx
      pushl %ecx
      pushl %edx

      xorl  %eax, %eax       #azzeramento dei registri
      xorl  %ebx, %ebx
      xorl  %ecx, %ecx
      xorl  %edx, %edx 
      
      jmp control           #salto al controllo(Salto incondizionato)
######################################################
next_one:
      inc %esi              #incremento del registro esi affinchè punti al prossimo carattere della stringa
######################################################
control:
      
      cmpb $32, (%esi)       #se è uno spazio, salto allo spazio
      je spazio

      cmpb $43, (%esi)      #se  è uno somma salto alla somma
      je som

      cmpb $45, (%esi)      #se  è un - salto a controllo segno
      je segno

      cmpb $47, (%esi)      #se è una divisione, salto alla divisione
      je div

      cmpb $42, (%esi)      #se è una moltiplicazione, salto alla moltiplicazione
      je mull

      cmpb $0, (%esi)       #se è il carattere di terminazione(\n) salto a fine funzione
      je end

      cmpb $10, (%esi)      #se è il "line feed" salto a fine funzione
      je next_one  
      jmp operando          #se non salta si prosegue a controllare se è un operando
######################################################    
segno:

      cmpb $0, 1(%esi)       #se il carattere successivo è il carattere di terminazione allora ho una sottazione
      je sot
      
      cmpb $32, 1(%esi)      #se il carattere successivo è uno spazio allora potrei avere una sottrazione
      je sot
      
      cmpb $10, 1(%esi)      #se il carattere successivo è IL "LINE FEED" allora ho una sottrazione
      je sot
       
      cmpb $48, 1(%esi)      #se il carattere successivo è < di 0 invalid
      jl inv
      
      cmpb $57, 1(%esi)      #se il carattere successivo è > di 9 invalid
      jg inv
    
      movl $1, neg           #se nessuno dei precedenti salti non avviene allora è un numero negativo
      jmp next_one
######################################################
operando:
      cmpb $48, (%esi)       #se è minore di 0 invalid
      jl inv
  
      cmpb $57, (%esi)       #se è maggiore di 9 invalid
      jg inv
#####################################################
take:

      xorl %ebx, %ebx        #azzeramento del registro
      xorl %edx, %edx        #azzeramento del registro

      movb (%esi), %bl       #assegno al registro edx del carattere puntato da esi es(mette 53 in bl)
      subl $48, %ebx         #assegno al registro del valore intero effetivo del carattere (53-48 = 5)
      
      movl $10, %edx         #assegno 10 ad ebx (rimetto il 10 in edx)
      mull %edx              #moltiplicazione di 10 per la precedente cifra(contenuta in eax) in caso di numero con più cifre(moltiplica il 3 con 10=30)
      
      addl %ebx, %eax        #somma di temp con value in caso di numero con più cifre (30+5=35)
      
      movb $0,operazione     #operazione trovato un numero quindi op=0 l'ho metto ogni volta perchè ricordo che è un numero

      jmp next_one
#####################################################
som:
    
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 

    cmpl $2, %ecx
    jl inv
    
    popl %eax                #pop dei valori dallo stack
    popl %ebx

    addl %ebx, %eax          # somma tra i registri

    pushl %eax               #push del risultato
    
    decl %ecx                #aggiorno il contattore delle push

    movb $1, operazione       #Operazione a 1 perchè + è un'operazione
    
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 


    jmp next_one             #vado al prossmo carattere
################################################# 
sot:

    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 

    cmpl $2, %ecx
    jl inv
    
    popl %ebx                #pop dei valori dallo stack
    popl %eax

    subl %ebx, %eax          # sottrazione tra i registri

    pushl %eax               #push del risultato
    
    decl %ecx                #aggiorno il contattore delle push

    movb $1, operazione      #Operazione a 1 perchè + è un'operazione
    
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 


    jmp next_one             #vado al prossmo carattere
####################################################### 
mull:

     
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 
    
    cmpl $2, %ecx
    jl inv

    popl %ebx                #pop dei valori dallo stack
    popl %eax

    imul %ebx                #moltiplicazione dei registri
 
    pushl %eax               #push del risultato
    
    decl %ecx                #decremento il contatore delle push
   
    movb $1, operazione      #operazione a 1 perchè ho eseguito un'operazione
   
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 
    
    jmp next_one              #proseguo con il prossimo carattere
###############################################
div:

    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 
    xorl %edx, %edx          #azzero pure edx perchè senno non fa le divisioni di numeri pos con quelli neg

    cmpl $2, %ecx
    jl inv

    popl %ebx                #pop dei valori dallo stack
    popl %eax
    idivl %ebx                #divisione dei registri con risultato intero
 
    pushl %eax               #push del risultato
    
    decl %ecx                #decremento il contatore delle push
   
    movb $1, operazione      #operazione a 1 perchè ho eseguito un'operazione
   
    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx 
    
    jmp next_one              #proseguo con il prossimo carattere
##################################################
spazio:

    cmpb $0, 1(%esi)            #se dopo lo spazio c'è uno spazio oppure dopo l'ultimo carattere di strina c'è uno spazio invalid
    je inv

    cmpb $10, 1(%esi)           #se il prossimo carattere è un "line feed", come sopra, significa che c'è uno spazio prima di fine stringa
    je inv

    cmpb $32, 1(%esi)           #se il prossim carattere è uno spazio,significa che ci sono più spazi
    je inv

    cmpb $1, operazione         #se è stata effetuata una operazione si prosegue alla lettura
    je next_one

     cmpb $0, neg               # se il numero non è negativo si passa direttamente al push
     je push 

     xorl %ebx, %ebx 
     movl $-1, %ebx             #assegno -1 al registro ebx
     mull %ebx                  #trasformo in numero negativo moltiplicando per -1
###############################################
push:
 
     movb $0, neg              #azzero il flag
     
     pushl %eax                 #metto il valore nello stack
     xorl %eax, %eax          
     incl % ecx                 #aggiorno il contatore delle push
     jmp next_one
##################################################
inv:
  
     cmpl $0, %ecx             #controllo delle push da ripristinare tramite il contatore
     je invalid2               #per evitare una pop di troppo

     popl %eax                 # ripristino dello stack
     loop inv                 #ritorna ad invalid solo se ecx è maggiore di zero             
#####################################################
invalid2:

    xorl %eax, %eax          #azzeramento dei registri
    xorl %ebx, %ebx
    leal error, %eax         #eax ora contiene il puntattore la stringa "invalid"
#######################################################
invalid_end:                  #mette una lettera alla volta in output

    movl (%eax), %ebx         #sposto il carattere puntato dal registro eax in ebx
    movl %ebx, (%edi)         #sposto il carattere da ebx al puntatore in output
    inc %eax                  #incremento il registro per puntare al 2 carattere
    inc %edi                  #incremento il registro per puntare al secondo spazio dell stringa in output
    
    cmpb $0, (%eax)            #se trovo il carattere di terminazione esco
    jne invalid_end
    movl $0, %ebx
    movl %ebx, (%edi)         #inserisco la terminazione  come ultimo carattere


    popl %edx                 #ripristino dei registri
    popl %ecx
    popl %ebx
    popl %eax

    ret                        #ritorno della funzione
###################################################
end:
 
      xorl  %eax, %eax         #azzeramento dei registri
      xorl  %ebx, %ebx
      xorl  %ecx, %ecx
      xorl  %edx, %edx 

      movl $10, %ebx 
      
      popl %eax                #salvo nel registro eax l'ultimo risultato

      movb $0, neg             #azzero il flag
      
      cmpl $0, %eax             #se il risultato è 0 o un numero positivo salto a risultato finale
      jge result 
      
      xorl %ebx, %ebx 
      movl $-1, %ebx           #assegno -1 al registro ebx
      mull %ebx                #moltiplico il risultato per - 1
      movb $1, neg             #metto a 1 il flag

      xorl  %ebx, %ebx         ##azzeramento dei registri
      xorl  %edx, %edx 
      
      movl $10, %ebx           #sposto 10 in ebx in preparazione alla prossima fase
###########################################
result:

      xorl  %edx, %edx         #azzero il resto
  
      divl %ebx                #divido per 10 il risultato  
      pushl %edx               #push del resto nello stack 
      incl %ecx                #incremento contatore push

      cmpl $0, %eax            #vedo se il risultato è stato azzerato
      jne result               #rimane in questo ciclo fino allo zeramento
    
      movl %edi, %edx          #salvo nel registro edx il puntatore al primo carattere della stringa di output
 
      cmpb $0, neg             #verifico se il flag è a zero o no
      je finish
      xorl %eax,%eax

      addl $45, %eax           #assegno il - ad eax
      movb %al, (%edi)         #carico il carattere - nella stringa di output 
      inc %edi                 #incremento edi per poter andare avanti a puntare il prossimo carattere
#########################################################
finish:
   
   xorl  %eax, %eax            #azzero eax
   popl %eax                   #scarico in eax la prima cifra del risultato
   addl $48, %eax              #trasformazione da valore a carattere
   movb %al, (%edi)            #salvo il valore nella posizione della stringa puntata

   inc %edi                    #incremento edi per poter andare avanti a puntare il prossimo carattere
   loop finish                 #loop fino all'esaurimento dei resto pushati nello stack

   movb $0, (%edi)             #fuori dal ciclo loop inserisco il carattere di terminazione
###################################################### 
exit:

    popl %edx                   #ripristino dei registri
    popl %ecx
    popl %ebx 
    popl %eax

ret
######################################################


