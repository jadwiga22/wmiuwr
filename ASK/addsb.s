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
        .globl  addsb
        .type   addsb, @function

/*
 * W moim rozwiązaniu używam następującej techniki: 

  Najpierw obliczam wynik, tak by zgadzał się on wewnątrz bajtów (nie uwzględniając przeniesień),
  tj. obliczam wynik dodawania tak, jakby to było dodawanie dwóch wektorów przechowujących typ unsigned
  i zapominam o przeniesieniu. Wynik tego działania oznaczę jako Res.

  Następnie generuję następujące maski:
  - maska Ov, która na LSB każdego bajtu ma 1 wtw, gdy dodawanie odp. bajtów wygenerowało overflow
  - maska Un, która na LSB każdego bajtu ma 1 wtw, gdy dodawanie odp. bajtów wygenerowało underflow
  - maska Ok, która na LSB każdego bajtu ma 1 wtw, gdy dodawanie odp. bajtów mieści się w zakresie

  Dalej aktualizuję Res. Zauważmy, że
  Res &= (Ok * 0xff)
  wyczyści wszystkie bajty, na których było over/underflow, natomiast pozostałe pozostawi bez zmian.

  Analogicznie
  Ov * 0x7f ma 0x7f na tych bajtach, gdzie było overflow, i 0 na pozostałych
  Un * 0x80 ma 0x80 na tych bajtach, gdzie było underflow i 0 na pozostałych

  Wobec tego ostateczny wynik to
  Res + Ov * 0x7f + Un * 0x80 = Res + 0x80 * (Ov + Un) - Ov

 */


addsb:
        /* Załadowanie odpowiednich bajtów (parzyste/nieparzyste) */

        mov     $0x00ff00ff00ff00ff, %rdx
        and     %rdi, %rdx

        mov     $0x00ff00ff00ff00ff, %rcx
        and     %rsi, %rcx

        mov     $0xff00ff00ff00ff00, %r8
        and     %rdi, %r8

        mov     $0xff00ff00ff00ff00, %r9
        and     %rsi, %r9
   

        add     %rcx, %rdx                      /* W rdx mamy sumę parzystych bajtów */
        add     %r9, %r8                        /* W r8 mamy sumę nieparzystych bajtów */


        mov     $0x00ff00ff00ff00ff, %r10       
        and     %rdx, %r10                      /* Usuwamy przeniesienie */
        mov     $0xff00ff00ff00ff00, %r9
        and     %r8, %r9                        /* Usuwamy przeniesienie */
        
        lea     (%r9, %r10, ), %rax             /* Ustawiamy wynik (jest on dobry dla bajtów, w których nie było overflow/underflow) */


        mov     $0x0101010101010101, %r9        /* Ustawiamy maskę, która pomoże wyciągać informacje o overflow/underflow */

        /* Wyciąganie inf. o underflow */

        mov     %rax, %rcx
        not     %rcx
        and     %rdi, %rcx
        and     %rsi, %rcx                      /* Wyciągamy informację o underflow (x & y & ~res) */
        shr     $7, %rcx                        /* Przesuwamy bit, na którym mamy inf. o underflow */
                                                /* Wewnątrz każdego bajtu LSB = 1 wtw, gdy było underflow */
        and     %r9, %rcx                       /* Czyścimy maskę - zostawiamy tylko interesujące nas pozycje */


        /* Wyciąganie inf. o overflow */

        or      %rsi, %rdi                      
        not     %rdi 
        and     %rax, %rdi                      /* Wyciągamy informację o overflow (~x & ~y & res) = (~(x | y) & res) */
        shr     $7, %rdi                        /* Przesuwamy bit, na którym mamy inf. o overflow */ 
                                                /* Wewnątrz każdego bajtu LSB = 1 wtw, gdy było overflow */
        and     %r9, %rdi                       /* Czyścimy maskę - zostawiamy tylko interesujące nas pozycje */


        /* Wyciąganie inf. o braku overflow ani underflow */
        /* Oznaczmy O - overflow, U - underflow */

        add     %rdi, %rcx                      /* U + O */
        sub     %rcx, %r9                       /* Wybieramy pozycje na których nie ma over/underflow */
                                                /* Brak O ani U <=> 1 - (U + O) */
                                                /* Wewnątrz każdego bajtu LSB = 1 wtw, gdy nie było ani over, ani underflow */
        imul    $0xff, %r9                      /* Ustawiamy 0xff na bajtach, gdzie nie ma O ani U */
        and     %r9, %rax                       /* Aktualizujemy wynik */
        
        /* Gdy U = 1, to chcemy ustawić bajt na 2^7 */
        /* Gdy O = 1, to chcemy ustawić bajt na 2^7-1 */

        imul    $0x80, %rcx                     /* (U + O) * 2^7 */
        add     %rcx, %rax                      /* Dodajemy (U + O) * 2^7 */
        sub     %rdi, %rax                      /* Odejmujemy O */

        ret

        .size   addsb, .-addsb
