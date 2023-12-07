:- use_module(library(theme/dark)).

empty_string(S) :- string_length(S, 0).

extract_numbers(Raw, Numbers) :-
  sub_string(Raw, _, _, After, ":"),
  sub_string(Raw, _, After, 0, T1),
  split_string(T1, " ", "", T2),
  convlist(atom_number, T2, Numbers).

extract(Input, Times, Distances) :-
  split_string(Input, "\n", "", [TimesRaw, DistancesRaw]),
  extract_numbers(TimesRaw, Times),
  extract_numbers(DistancesRaw, Distances).

greater(Time, Distance, Acc, Res) :-
  Start is floor(Time/2 - sqrt(Time^2/4 - Distance) + 1),
  End is ceiling(Time/2 + sqrt(Time^2/4 - Distance) - 1),
  Res is Acc * (End - Start + 1).

main :-
  read_file_to_string("/Users/dahlbaek/AoC/2023/sixth/sixth.txt", Input, []),
  extract(Input, Times, Distances),
  foldl(greater, Times, Distances, 1, Part1),
  format("Part1: ~d\n", [Part1]),
  re_replace(" "/g, "", Input, Input2),
  extract(Input2, Times2, Distances2),
  foldl(greater, Times2, Distances2, 1, Part2),
  format("Part2: ~d\n", [Part2]).

  
