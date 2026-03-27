content("
# Plog update

I bring good news lovely prolog developers! This prolog blog system (plog) has recivied new updates that I am going to enumerate right now.

First of all, I have updated the markdown parser and it can now recognize **codeblocks**! This one was a bit tricky because it involved creating a new rule that stored all the lines read between two fenced codeblocks. For example, I can easily copy the new prolog rule and it will be rendered inside a `<pre><code>` tag:

```prolog
collect_code_block([Line|Rest], [], Rest) :-
    string_concat('```', _, Line), !.
collect_code_block([], [], []).
collect_code_block([Line|Rest], [Line|CodeRest], Remaining) :-
    collect_code_block(Rest, CodeRest, Remaining).
```

> I guess more post styles will be coming soon...

Another small changed is that the **strong** and _italic_ tags are rendered as `<strong>` and `<em>` respectively. This makes the web a more accesible place everyone, specially screen-reader users.

Also, new lines are correctly displayed. Previous version would create an empty `<p>` tag for every blank line in the markdown file.

The final change, I have refactored the code base and all the markdown renderer logic lives inside the `md_parser.pl` file. The `main.pl` was getting too large imo and one can get easily lost trying to understand all prolog rules interactions.

Ordered and unordered list will be my next objective, as well as an easier customization for anyone who wants to deploy it's own plog instance. Any contribution is welcomed, so feel free to make any PR or open any issue.

Nothing further to add,
Yeray
").
