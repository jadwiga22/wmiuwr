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
        .globl  mod17
        .type   mod17, @function

/*
 * W moim rozwiązaniu używam następującej techniki: 

  Najpierw obliczam osobno sumy parzystych i nieparzystych półbajtów
  (cyfr w systemie szesnastkowym) - oznaczmy je odpowiednio P i NP . 

  Następnie obliczam wynik = P - NP. Wówczas -120 <= wynik <= 120,
  ponieważ 0 <= P, NP <= 8*15 = 120

  Do wyniku dodaję 136 = 8 * 17, gdy wynik < 0.

  Następnie znajduję największe k, takie że wynik - 17*k >=0
  i obliczam wynik = wynik - 17*k.

  Takie k znajduję przy pomocy odejmowania od wyniku liczb postaci 17*l, 
  gdzie l jest potęgą dwójki (równą 1, 2 lub 4).

 */


mod17:

        /* Obliczanie sum półbajtów parzystych i nieparzystych */

        mov     $0x0f0f0f0f0f0f0f0f, %rax       /* maska na parzyste półbajty */

        and     %rdi, %rax                      /* wyciągamy parzyste półbajty */ 
        sub     %rax, %rdi                      /* wyciągamy nieparzyste półbajty */

        mov     %rdi, %r9                       /* obliczamy sumy par półbajtów */
        mov     %rax, %r10
        shr     $32, %r9
        shr     $32, %r10
        add     %r9, %rdi
        add     %r10d, %eax                     /* dodajemy, zerując górną połowę bajtów */

        shl     $28, %rdi                       /* scalamy pary półbajtów parzystych i nieparzystych do jednego rejestru */
        or      %rdi, %rax  

        mov     %rax, %r10                      /* obliczamy sumy czwórek półbajtów */
        shr     $16, %r10
        add     %r10, %rax

        mov     %rax, %r10                      /* obliczamy sumy ósemek półbajtów */
        shr     $8, %r10
        add     %r10, %rax

        mov     %rax, %rdx                      
        and     $0xff, %eax                     /* usuwamy śmieci z bajtów niezawierających wyniku */
        shr     $32, %rdx                       /* przesuwamy wynik dla nieparzystych półbajtów */
        and     $0xff, %edx                     /* usuwamy śmieci z bajtów niezawierających wyniku */


        /* Obliczanie modulo 17 */

        mov     $136, %esi                      /* przygotowujemy stałą (136 = 17 * 8) */

        sub     %edx, %eax                      /* wynik = parzyste - nieparzyste */

        lea     (%esi, %eax, ), %esi            /* wynik + 136 (bez zapalania flag) */
        cmovl   %esi, %eax                      /* gdy wynik był ujemny, to dodajemy 136 */

        mov     %eax, %edx                      /* jeśli wynik >= 68, to odejmujemy 68 */
        sub     $68, %edx
        cmovns  %edx, %eax

        mov     %eax, %edx                      /* jeśli wynik >= 34, to odejmujemy 34 */
        sub     $34, %edx
        cmovns  %edx, %eax

        mov     %eax, %edx                      /* jeśli wynik >= 17, to odejmujemy 17 */
        sub     $17, %edx
        cmovns  %edx, %eax

        ret

        .size   mod17, .-mod17
