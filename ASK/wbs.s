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
        .globl  wbs
        .type wbs, @function

/*
 * W moim rozwiązaniu używam następującej techniki: 

  Pomocniczo obliczam zwykłe sumy bitów. Korzystam z następującej obserwacji:

  Niech
        - WL - suma ważona bardziej znaczących k bitów
        - WR - suma ważona mniej znaczących k bitów
        - L - zwykła suma bardziej znaczących k bitów
        - R - zwykła suma mniej znaczących k bitów
        - W - suma ważona 2k bitów
  Wówczas
        W = WL + WR + L*k

  Ostatnie iteracje przyspieszam poprzez zauważenie, że przy przemnożeniu
  przez odpowiednią stała, mogę otrzymać sumę zwykłych sum bajtów z odp.
  współczynnikami, która wyląduje na najbardziej znaczącym bajcie. 

  Analogicznie mogę szybko zsumować sumy ważone par bajtów.

  Ostateczny wynik obliczam przez dodanie dwóch powyższych.

 */

wbs:
        /* suma bitów (zwykła) : rdi, suma bitów (ważona) : rax */


        /* kubełki dłg. 2 */

        mov     $0x5555555555555555, %rsi               /* maska wyciągająca parzyste bity */

        lea     (%rdi), %rax
        and     %rsi, %rdi 
        shr     $1, %rax
        and     %rsi, %rax                              /* ważona suma par bitów */
           
        lea     (%rax, %rdi), %rdi                      /* zwykła suma par bitów */


        /* kubełki dłg. 4 */

        mov     $0x3333333333333333, %rsi               /* maska wyciągająca parzyste pary bitów */

        imul    $5, %rax
        shr     $2, %rax
        and     %rsi, %rax                              /* zsumowanie ważonych sum z poprz. iteracji */

        lea     (%rdi), %rdx
        shr     $2, %rdi
        and     %rsi, %rdi                              /* zwykłe sumy lewych par */
        lea     (%rax, %rdi, 2), %rax                   /* dodanie dwukrotności zwykłych sum lewych par do sumy ważonej */
        and     %rsi, %rdx                              /* oczyszczenie maski */
        
        lea     (%rdi, %rdx), %rdx                      /* zwykła suma czwórek bitów */   


        /* kubełki dłg. 8 */

        mov     $0x0f0f0f0f0f0f0f0f, %rsi               /* maska wyciągająca parzyste czwórki bitów */
        mov     $0xf0f0f0f0f0f0f0f0, %rdi               /* maska wyciągająca nieparzyste czwórki bitów */

        mov     %rax, %rcx
        and     %rdx, %rdi

        shr     $4, %rax
        shr     $4, %rdi

        lea     (%rcx, %rax), %rax                      /* zsumowanie ważonych sum z poprz. iteracji */
        and     %rsi, %rax                              /* oczyszczenie maski */
        and     %rsi, %rdx                              /* oczyszczenie maski */
        lea     (%rax, %rdi, 4), %rax                   /* dodanie czterokrotności zwykłych sum lewych czwórek do sumy ważonej */

        lea     (%rdi, %rdx), %rdi                      /* zwykła suma ósemek bitów */


        /* kubełki dłg. 16 */

        mov     $0x00ff00ff00ff00ff, %rsi               /* maska wyciągająca parzyste bajty */

        mov     %rax, %rcx
        mov     %rdi, %rdx

        shr     $8, %rax
        shr     $8, %rdi

        lea     (%rcx, %rax), %rax                      /* zsumowanie ważonych sum z poprz. iteracji */
        and     %rsi, %rdi                              /* oczyszczenie maski */
        and     %rsi, %rax                              /* oczyszczenie maski */        
        lea     (%rax, %rdi, 8), %rax                   /* dodanie ośmiokrotności zwykłych sum lewych bajtów do sumy ważonej */  


        /* ostateczny wynik */                          

        mov     $0x0001000100010001, %rsi               
        mov     $0x0000020204040606, %rcx

        imul    %rsi, %rax                              /* szybkie zsumowanie ważonych sum par bajtów */
        imul    %rcx, %rdx                              /* szybkie zsumowanie zwykłych sum bajtów z odp. współczynnikami */
        
        shr     $48, %rax
        shr     $56, %rdx
        lea     (%eax, %edx, 8), %eax                   /* dodanie sum zwykłych do sumy ważonej z odp. współczynnikiem */
        

        
        ret

        .size wbs, .-wbs
