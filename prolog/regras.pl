vitoria(Piloto) :-
    corrida(Piloto, _, _, _, 1, _, _, _).

total_vitorias(Piloto, Total) :-
    findall(1, vitoria(Piloto), Lista),
    length(Lista, Total).


pontos_piloto(Piloto, Total) :-
    findall(P, corrida(Piloto, _, _, _, _, P, _, _), Lista),
    sum_list(Lista, Total).


ganho_posicao(Piloto, Ganho) :-
    corrida(Piloto, _, _, Largada, Posicao, _, _, _),
    Largada > 0,
    Posicao > 0,
    Ganho is Largada - Posicao.


total_ganho(Piloto, Total) :-
    findall(G, ganho_posicao(Piloto, G), Lista),
    sum_list(Lista, Total).


media_posicao(Piloto, Media) :-
    findall(Pos, (
        corrida(Piloto, _, _, _, Pos, _, _, _),
        Pos > 0
    ), Lista),
    sum_list(Lista, Soma),
    length(Lista, N),
    N > 0,
    Media is Soma / N.


pontos_nacionalidade(Nac, Total) :-
    findall(P, corrida(_, _, _, _, _, P, _, Nac), Lista),
    sum_list(Lista, Total).


ranking_pilotos(ListaOrdenada) :-
    setof(Piloto, Equipe^GP^L^Pos^Pts^Ano^Nac^corrida(Piloto, Equipe, GP, L, Pos, Pts, Ano, Nac), Pilotos),
    findall(Total-P,
        (
            member(P, Pilotos),
            pontos_piloto(P, Total)
        ),
        Lista),
    sort(Lista, ListaOrdenada1),
    reverse(ListaOrdenada1, ListaOrdenada).


melhor_piloto(Piloto) :-
    ranking_pilotos([_-Piloto | _]).


media_ganho(Piloto, Media) :-
    findall(G, ganho_posicao(Piloto, G), Lista),
    sum_list(Lista, Soma),
    length(Lista, N),
    N > 0,
    Media is Soma / N.


melhor_ganho(Piloto, Max) :-
    findall(G, ganho_posicao(Piloto, G), Lista),
    max_list(Lista, Max).


campeao_ano(Ano, Piloto) :-
    setof(P, E^L^Pos^Pts^Nac^corrida(P, E, _, L, Pos, Pts, Ano, Nac), Pilotos),
    findall(Total-P,
        (
            member(P, Pilotos),
            findall(Pts,
                corrida(P, _, _, _, _, Pts, Ano, _),
                Lista),
            sum_list(Lista, Total)
        ),
        Ranking),
    sort(Ranking, Ordenado),
    reverse(Ordenado, [_-Piloto | _]).


pontos_construtor(Equipe, Total) :-
    findall(P,
        corrida(_, Equipe, _, _, _, P, _, _),
        Lista),
    sum_list(Lista, Total).


campeao_construtor(Ano, Equipe) :-
    setof(E, P^L^Pos^Pts^Nac^corrida(P, E, _, L, Pos, Pts, Ano, Nac), Equipes),
    findall(Total-E,
        (
            member(E, Equipes),
            findall(Pts,
                corrida(_, E, _, _, _, Pts, Ano, _),
                Lista),
            sum_list(Lista, Total)
        ),
        Ranking),
    sort(Ranking, Ordenado),
    reverse(Ordenado, [_-Equipe | _]).


todos_campeoes :-
    setof(Ano, P^E^L^Pos^Pts^Nac^corrida(P, E, _, L, Pos, Pts, Ano, Nac), Anos),
    forall(member(A, Anos),
        (
            campeao_ano(A, P),
            write(A), write(' - '), write(P), nl
        )).