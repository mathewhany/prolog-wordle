main:-
    write('Welcome to Pro-Wordle!'), nl,
    write('----------------------'), nl,
    build_kb,
    play.

build_kb:-
    write('Please enter a word and its category on separate lines:'), nl,
    read(W), 
    (
        var(W),
        write('You cannot enter variables, try again.'), nl,
        build_kb
    ;
        W = 'done',
        write('Done building the words database...'), nl
    ;
        read(C),
        (   
            var(C),
            write('You cannot enter variables, try again.'), nl,
            build_kb
        ;
            assert(word(W, C)),
            build_kb
        )
    ).

play:-
    write('The available categories are: '),
    categories(Categories),
    write(Categories), nl,
    choose_category(C),
    choose_length(L, C),
    Guesses is L + 1,
    write('Game started. You have '), write(Guesses), write(' guesses.'), nl, nl,
    setof(W, pick_word(W, L, C), Words),
    random_member(ActualWord, Words),
    guess_word(ActualWord, L, Guesses).

pick_word(W, L, C):-
    word(W, C),
    atom_length(W, L).

choose_category(C):-
    write('Choose a category: '), nl,
    read(T),
    (
        var(T),
        write('You cannot enter variables, try again.'), nl,
        choose_category(C)
    ;
        is_category(T),
        C = T
    ;
        write('This category does not exist.'), nl,
        choose_category(C)
    ).

choose_length(L, C):-
    write('Choose a length: '), nl,
    read(T),
    (
        var(T),
        write('You cannot enter variables, try again.'), nl,
        choose_length(L, C)
    ;
        \+integer(T),
        write('You must enter a number, try again.'), nl,
        choose_length(L, C)
    ;
        pick_word(_, T, C),
        L = T
    ;
        write('There are no words of this length. '), nl,
        choose_length(L, C)
    ).

guess_word(ActualWord, RequiredLength, Guesses):-
    write('Enter a word composed of '), write(RequiredLength), write(' letters:'), nl,
    read(GuessWord),
    (
        var(GuessWord),
        write('You cannot enter variables, try again.'), nl,
        guess_word(ActualWord, RequiredLength, Guesses)
    ;
        GuessWord = ActualWord,
        write('You won!'), nl
    ;
        Guesses = 1,
        write('You lost!'), nl
    ;
        (
            atom_length(GuessWord, RequiredLength),            
            atom_chars(ActualWord, ActualLetters),
            atom_chars(GuessWord, GuessLetters),
            correct_letters(ActualLetters, GuessLetters, CorrectLetters),
            correct_positions(ActualLetters, GuessLetters, CorrectPositions),
            write('Correct letters are: '), write(CorrectLetters), nl,
            write('Correct letters in correct positions are: '), write(CorrectPositions), nl,
            NewGuesses is Guesses - 1
        ;
            write('Word is not composed of '), write(RequiredLength), write(' letters. Try again.'), nl,
            NewGuesses is Guesses
        ),
        write('Remaining Guesses are '), write(NewGuesses), nl, nl,
        guess_word(ActualWord, RequiredLength, NewGuesses)
    ).


correct_letters(ActualLetters, GuessLetters, CorrectLetters):-
    intersection(GuessLetters, ActualLetters, CL),
    list_to_set(CL, CorrectLetters).

correct_positions([], [], []).
correct_positions([H|T1], [H|T2], [H|T3]):-
    correct_positions(T1, T2, T3).
correct_positions([H1|T1], [H2|T2], T3):-
    H1 \= H2,
    correct_positions(T1, T2, T3).

is_category(C):-
    word(_, C).

categories(L):-
    setof(X, is_category(X), L).

available_length(L):-
    word(W, _),
    atom_length(W, L).