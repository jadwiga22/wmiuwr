/*
 * UWAGA! W poniższym kodzie należy zawrzeć krótki opis metody rozwiązania
 *        zadania. Będzie on czytany przez sprawdzającego. Przed przystąpieniem
 *        do rozwiązywania zapoznaj się dokładnie z jego treścią. Poniżej należy
 *        wypełnić oświadczenie o samodzielnym wykonaniu zadania.
 *
 * Oświadczam, że zapoznałem(-am) się z regulaminem prowadzenia zajęć
 * i jestem świadomy(-a) konsekwencji niestosowania się do podanych tam zasad.
 *
 * Imię i nazwisko, numer indeksu: Jadwiga Świerczyńska, 330498
 */

        .text
        .globl  bitrev
        .type bitrev, @function

/*
 * W moim rozwiązaniu używam następującej techniki: 

 Najpierw odwracam wnętrze poszczególnych półbajtów, tj. zamieniam ciąg bajtów 
 (63, 62, 61, 60, ..., 5, 4, 3, 2, 1, 0)
 na ciąg
 (60, 61, 62, 63, 56, 57, 58, 59, ..., 7, 6, 5, 4, 3, 2, 1, 0)

 Następnie zamieniam kolejnością sąsiednie półbajty, tj. zamieniam ciąg półbajtów
 (15, 14, 13, 12, 11, ..., 3, 2, 1, 0)
 na ciąg
 (14, 15, 12, 13, 10, 11, ..., 2, 3, 0, 1)

 Na koniec odwracam kolejność bajtów, tj. zamieniam ciąg bajtów
 (A, B, C, D, E, F, G, H)
 na ciąg
 (H, G, F, E, D, C, B, A)

 Jest to zoptymalizowanie techniki polegającej na zamienianiu par sąsiednich bitów,
 potem par sąsiednich "kubełków" dwubitowych,
 potem par sąsiednich "kubełków" czterobitowych,
 ...,
 potem par sąsiednich "kubełków" 32-bitowych
 */

bitrev:
        /* Odwracanie czwórek bitów (czyli odwracanie półbajtów) */    

        mov     $0x4444444444444444, %rsi       /* Wyciągamy 2. bit z półbajtu */
        and     %rdi, %rsi
        mov     $0x2222222222222222, %rdx       /* Wyciągamy 1. bit z półbajtu */
        and     %rdi, %rdx
        mov     $0x1111111111111111, %rcx       /* Wyciągamy 0. bit z półbajtu */
        and     %rdi, %rcx
        mov     $0x8888888888888888, %rax       /* Wyciągamy 0. bit z półbajtu */
        and     %rax, %rdi

        shr     %rsi                            /* Przesuwamy 2. bity na 1. miejsce  */
        lea     (%rsi, %rdx, 2), %rsi           /* Przesuwamy 1. bity na 2. miejsce i łączymy wyniki */
        shr     $3, %rdi                        /* Przesuwamy 3. bity na 0. miejsce */
        lea     (%rdi, %rcx, 8), %rax           /* Przesuwamy 0. bity na 3. miejsce i łączymy wyniki */
        add     %rsi, %rax                      /* Łączymy wyniki */
        
        /* Zamienianie miejscami sąsiednich półbajtów */

        mov     %rax, %rdi                      /* Kopiujemy rax */                
        shr     $4, %rax                        /* Przesuwamy półbajty */
        mov     $0x0f0f0f0f0f0f0f0f, %rcx       /* Przygotowujemy maskę */
        and     %rcx, %rax                      /* Wyciągamy półbajty, które będą parzyste po zamianie */
        and     %rcx, %rdi                      /* Wyciągamy półbajty, które będą nieparzyste po zamianie */
        shl     %rdi                            /* Przesuwamy półbajty nieparzyste o 1 miejsce */
        lea     (%rax, %rdi, 8), %rax           /* Przesuwamy półbajty nieparzyste o 3 miejsca i łączymy wyniki */


        /* Odwracanie kolejności bajtów */

        mov     %eax, %edi                      /* Bierzemy dolne bajty (E F G H) */
        ror     $8, %di                         /* Zamieniamy kolejność (E F H G) */
        ror     $16, %edi                       /* Zamieniamy kolejność (H G E F) */
        ror     $8, %di                         /* Zamieniamy kolejność (H G F E) */

        shr     $32, %rax                       /* Bierzemy górne bajty (A B C D) */
        ror     $8, %ax                         /* Zamieniamy kolejność (A B D C) */
        ror     $16, %eax                       /* Zamieniamy kolejność (D C A B) */
        ror     $8, %ax                         /* Zamieniamy kolejność (D C B A) */

        shl     $32, %rdi                       /* Przesuwamy (H G F E 0 0 0 0) */
        or      %rdi, %rax                      /* Łączymy wyniki (H G F E D C B A) */
        
   
        ret

        .size bitrev, .-bitrev
