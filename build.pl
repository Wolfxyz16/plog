% Copyright © 2026 wolfxyz
% Licensed under the Apache License 2.0.
% See the LICENSE file for details or http://www.apache.org/licenses/LICENSE-2.0.

% The goal of this module is to create and generate all html files inside the public directory

:- module(build, [generate_public/0]).

:- use_module(style).
:- use_module(md_parser).

:- use_module(library(http/html_write)).
:- use_module(library(http/http_dispatch)).

% home page definition and html generation
home_page(Blogs) :-
    predsort(compare_by_published_desc, Blogs, SortedBlogs),
    Head = [title('~yeray'), script([defer, src('https://umami.yerayliloaiza.cc/script.js'), 'data-website-id'('18f64e61-7751-47d3-ad01-44f7532d3015')], []), \page_style],
    Body = [\main_body(SortedBlogs)],
    phrase(page(Head, Body), Tokens),
    print_html(Tokens).

main_body(SortedBlogs) -->
    html([
      header([id(header)], [
        h1('Yeray Li Loaiza'),
        h3('AI Developer and software libre enthusiast')
      ]),
      main([id(content)], [
        section([id(meta)], [
          p('Welcome to my personal web page. Here you will find the projects I am currently working on and you can read about my opinion in different topics. Take a seat and enjoy!'),
          figure([], [
            img([src('/images/profile.webp'), alt('Picture of myself in a taiwanese elevator')]),
	    figcaption("pic of me!")
          ])
        ]),
        table([ \header | \rows(SortedBlogs) ])
      ])
    ]).


header --> 
    html(tr([   th([class(title)], 'Title'), th([class(desc)],  ''), th([class(time)], 'Created at')])).

% add description logic so posts can have different categories
rows([]) --> [].
rows([Blog|Blogs]) -->
    html(tr([
        td([class(title)], \blog_link(Blog)),
	td([class(desc)], ""),
        td([class(time)], \get_published_at(Blog))
    ])),
    rows(Blogs).

get_published_at(Blog) -->
    { Blog = blog(_, _, date(Y, M, D), _, _) },
    { format(atom(DateStr), '~w-~w-~w', [Y, M, D]) },
    html(DateStr).

compare_by_published_desc(Order, Blog1, Blog2) :-
    Blog1 = blog(_, _, Date1, _, _),
    Blog2 = blog(_, _, Date2, _, _),
    compare(Order, Date2, Date1).

blog_link(Blog) -->
    {
      Blog = blog(title(Title), _, _, _, path(Path)),
      file_base_name(Path, X), file_name_extension(Base, _, X),
      http_link_to_id(blog_handler, [name=Base], HREF) 
    },
    html(a(href(HREF), Title)).

read_blog(Path, Blog) :-
    setup_call_cleanup(
        consult(Path),
        (
            title(T),
            author(A),
            date(Y, M, D),
            findall(P, content(P), Ps),
    	    [Innerparagraphs] = Ps,
            split_string(Innerparagraphs, "\n", "", ParagraphLines),
            Blog = blog(title(T), author(A), date(Y, M, D), paragraphs(ParagraphLines), path(Path))
        ),
        unload_file(Path)
    ).

render_blog(Blog) :-
    Blog = blog(title(T), author(A), date(Y, M, D), paragraphs(Ps), path(_)),
    format(atom(DateStr), '~w-~w-~w', [Y, M, D]),
    render_paragraphs(Ps, HtmlParagraphs),
    Head = [title(T), meta([name(author), content(A)]), meta([name(date), content(DateStr)]), \blog_style],
    Body = [article(id(content), HtmlParagraphs)],
    phrase(page(Head, Body), Tokens),
    print_html(Tokens).

%
% Generation rules
%
generate_public :-
  (   exists_directory('public')
  ->  delete_directory_contents('public')
  ;   make_directory('public')
  ),
  (   exists_directory('public/posts')
  ->  delete_directory_contents('public/posts')
  ;   make_directory('public/posts')
  ),
  expand_file_name('./contents/*', FilePaths),
  maplist(read_blog, FilePaths, Blogs),
  maplist(generate_posts_files, Blogs),
  setup_call_cleanup(
    open('public/index.html', write, Stream), 
    with_output_to(Stream, home_page(Blogs)), 
    close(Stream)
  ).
  
generate_posts_files(Blog) :-
  Blog = blog(_, _, _, _, path(Path)),
  file_base_name(Path, X), file_name_extension(Base, _, X),
  format(string(GeneratedPath), "./public/posts/~w.html", Base),
  setup_call_cleanup(
    open(GeneratedPath, write, Stream), 
    with_output_to(Stream, render_blog(Blog)), 
    close(Stream)
  ).
