:- module(md_parser, [render_paragraphs/2]).

render_paragraphs([], []).

render_paragraphs([Line|Rest], Out) :-
  normalize_space(string(Normalized), Line),
  Normalized == "", !,
  render_paragraphs(Rest, Out).

render_paragraphs([Line|Rest], [pre(code([class(LanguageName)],Codeblock))|Out]) :-
  string_concat("```", LanguageName, Line), !,
  collect_code_block(Rest, CodeLinesList, RemainingLines),
  atomic_list_concat(CodeLinesList, '\n', Codeblock),
  render_paragraphs(RemainingLines, Out).

render_paragraphs([Line|Rest], [HTML|Out]) :-
    (
        re_matchsub("^# +(.*)", Line, D, []) -> HTML = h1(D.get(1));
        re_matchsub("^## +(.*)", Line, D, []) -> HTML = h2(D.get(1));
        re_matchsub("^### +(.*)", Line, D, []) -> HTML = h3(D.get(1));
        re_matchsub("^> +(.*)", Line, D, []) -> HTML = blockquote(p(D.get(1)));
        re_matchsub("^---$", Line, _, []) -> HTML = hr([]);
        inline(Line, Parts),
        HTML = p(Parts)

    ),
    render_paragraphs(Rest, Out).

collect_code_block([Line|Rest], [], Rest) :-
    string_concat("```", _, Line), !.
collect_code_block([], [], []).
collect_code_block([Line|Rest], [Line|CodeRest], Remaining) :-
    collect_code_block(Rest, CodeRest, Remaining).


inline(Line, Parts) :-
(   re_matchsub("^(.*?)\\!\\[(.*?)\\]\\((.*?)\\)(.*)$", Line, D, []) ->
    B = D.get(1),
    T = D.get(2),
    U = D.get(3),
    A = D.get(4),
    inline(B, PBefore),
    inline(A, PAfter),
    append(PBefore, [img([src(U), width('450'), height('400'), alt(T)])|PAfter], Parts);

    re_matchsub("^(.*?)\\[(.*?)\\]\\((.*?)\\)(.*)$", Line, D, []) ->
    B = D.get(1),
    T = D.get(2),
    U = D.get(3),
    A = D.get(4),
    inline(B, PBefore),
    inline(A, PAfter),
    append(PBefore, [a([href(U)], T)|PAfter], Parts);

    re_matchsub("^(.*?)`(.*?)`(.*)$", Line, D, []) ->
    B = D.get(1),
    M = D.get(2),
    A = D.get(3),
    inline(B, PBefore),
    inline(A, PAfter),
    append(PBefore, [code(M)|PAfter], Parts);

    re_matchsub("^(.*?)\\*\\*(.*?)\\*\\*(.*)$", Line, D, []) ->
    B = D.get(1),
    M = D.get(2),
    A = D.get(3),
    inline(B, PBefore),
    inline(A, PAfter),
    append(PBefore, [strong(M)|PAfter], Parts);

    re_matchsub("^(.*?)_(.*?)_(.*)$", Line, D, []) ->
    B = D.get(1),
    M = D.get(2),
    A = D.get(3),
    inline(B, PBefore),
    inline(A, PAfter),
    append(PBefore, [em(M)|PAfter], Parts);
    
    Parts = [Line]
).
