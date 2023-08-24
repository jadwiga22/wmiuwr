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
        .globl  clz
        .type   clz, @function

/*
 * W moim rozwiązaniu używam następującej techniki: 

 Przy pomocy wyszukiwania binarnego znajduję najmniejsze k >= 0, takie że
 maska o jedynkach na bitach od 63-k do 63 i o zerach na pozostałych bitach (od 0 do 63-k-1)
 po "zandowaniu" z przekazanym argumentem daje liczbę różną od 0.

 Jeśli takie k nie istnieje, to liczba ma 0 zer wiodących (ten przypadek uwzględniam na końcu).
 W przeciwnym razie k+1 jest liczbą zer wiodących.
 */

clz:
        xor     %eax,%eax                       /* Tutaj robię coś bardzo ważnego! */
        mov     $32, %ecx                       /* ustawienie środka przedziału */

        /* Iteracja 1: długość przedziału wyszukiwania = 64 */

        testq   $0xffffffff80000000, %rdi       /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski startowej */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

        /* Iteracja 2: długość przedziału wyszukiwania = 32 */
                          
        lea    16(%eax), %ecx                   /* obliczamy średnią arytmetyczną (środek) */

        movq    $0x8000000000000000, %rdx       /* ustawiamy pierwszy bit maski na 1 */
        sarq    %ecx, %rdx                      /* rozsmarowujemy 1 po masce */ 
        testq   %rdx, %rdi                      /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

        /* Iteracja 3: długość przedziału wyszukiwania = 16 */

        lea    8(%eax), %ecx                   /* obliczamy średnią arytmetyczną (środek) */

        movq    $0x8000000000000000, %rdx       /* ustawiamy pierwszy bit maski na 1 */
        sarq    %ecx, %rdx                      /* rozsmarowujemy 1 po masce */ 
        testq   %rdx, %rdi                      /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

         /* Iteracja 4: długość przedziału wyszukiwania = 8 */

        lea    4(%eax), %ecx                   /* obliczamy średnią arytmetyczną (środek) */

        movq    $0x8000000000000000, %rdx       /* ustawiamy pierwszy bit maski na 1 */
        sarq    %ecx, %rdx                      /* rozsmarowujemy 1 po masce */ 
        testq   %rdx, %rdi                      /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

        /* Iteracja 5: długość przedziału wyszukiwania = 4 */

        lea    2(%eax), %ecx                   /* obliczamy średnią arytmetyczną (środek) */

        movq    $0x8000000000000000, %rdx       /* ustawiamy pierwszy bit maski na 1 */
        sarq    %ecx, %rdx                      /* rozsmarowujemy 1 po masce */ 
        testq   %rdx, %rdi                      /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

         /* Iteracja 6: długość przedziału wyszukiwania = 2 */

        lea    1(%eax), %ecx                   /* obliczamy średnią arytmetyczną (środek) */

        movq    $0x8000000000000000, %rdx       /* ustawiamy pierwszy bit maski na 1 */
        sarq    %ecx, %rdx                      /* rozsmarowujemy 1 po masce */ 
        testq   %rdx, %rdi                      /* patrzymy, czy jest zapalone cokolwiek na pozycjach z maski */
        cmove   %ecx, %eax                      /* przesuwamy dolną granicę (nie znaleźliśmy 1) */

        /* Ostateczny wynik */
        
        shl     %rdi                            /* zapalamy CF, jeśli 1 stoi na pierwszym miejscu */
        sbb     $-1, %eax                       /* dodajemy 1 do wyniku (lub 0, gdy na 63. bicie stoi 1) */
        ret

        .size   clz, .-clz
