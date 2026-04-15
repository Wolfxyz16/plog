% Copyright © 2026 wolfxyz
% Licensed under the Apache License 2.0.
% See the LICENSE file for details or http://www.apache.org/licenses/LICENSE-2.0.

% The goal of this module is to create and generate all html files inside the public directory

:- module(build, [generate_public/0]).

:- use_module(style).
:- use_module(md_parser).

:- use_module(library(http/html_write)).
:- use_module(library(http/http_dispatch)).

generate_public :-
  (   exists_directory('public')
  ->  delete_directory_contents('public')
  ;   make_directory('public')
  ),
  (   exists_directory('public/posts')
  ->  delete_directory_contents('public/posts')
  ;   make_directory('public/posts')
  ),
  setup_call_cleanup(
    open('public/index.html', write, Stream), 
    with_output_to(Stream, home_page), 
    close(Stream)
  ),
  expand_file_name('./contents/*', FilePaths),
  forall(member(Path, FilePaths), generate_posts_files(Path)).
  
generate_posts_files(Path) :-
  sub_string(Path, 11, _, 3, FileName),
  format(string(GeneratedPath), "./public/posts/~w.html", FileName),
  setup_call_cleanup(
    open(GeneratedPath, write, Stream), 
    with_output_to(Stream, list_blog(Path)), 
    close(Stream)
  ).

% home page definition and html generation
home_page :-
    expand_file_name('./contents/*', FilesPaths),
    predsort(compare_by_published_desc, FilesPaths, SortedFiles),
    phrase(page( [ title('Yeray Li Loaiza'), \page_style ], [ \main_body(SortedFiles) ] ), Tokens),
    print_html(Tokens).

main_body(SortedFiles) -->
    html([
      header([id(header)], [
        h1('Yeray Li Loaiza'),
        h3('AI Developer and software libre enthusiast')
      ]),
      main([id(content)], [
        section([id(meta)], [
          p('Welcome to my personal web page. Here you will find the projects I am currently working on and you can read about my opinion in different topics. Take a seat and enjoy!'),
          figure([], [
            img([src('/images/profile.webp'), alt('picture of me in Shanghai!')]),
            figcaption(a([href('https://github.com/cryptoque/prolog-blog-engine'), target('_blank')], 'This blog has been created using this awesome project!'))
          ])
        ]),
        table([ \header | \blogs(SortedFiles) ])
      ])
    ]).


header --> 
    html(tr([   th([class(title)], 'Title'), th([class(desc)],  ''), th([class(time)], 'Last Updated At')])).

blogs([]) --> [].
blogs([PrologPath|T]) --> 
    {sub_string(PrologPath, 11, _, 3, H),get_blog_display_name(H, H0)},
    html(tr([td([class(title)], \blog_link(H0, H)), td([class(desc)], ''), td([class(time)], \get_published_at(PrologPath))])),
    blogs(T).

get_published_at(Blog) -->
    { file_info(Blog, _, Created) },
    { format_timestamp(Created, CreatedFormatted) },
    html(CreatedFormatted).

compare_by_published_desc(Order, BlogA, BlogB) :-
    file_info(BlogA, _, TimeA),
    file_info(BlogB, _, TimeB),
    compare(Order, TimeB, TimeA).

blog_link(Blog, Display) -->
    { http_link_to_id(blog_handler, [name=Display], HREF) },
    html(a(href(HREF), Blog)).

list_blog(Blog) :-
    read_blog_files(Blog, Paragraphs),
    [Innerparagraphs] = Paragraphs,
    split_string(Innerparagraphs, "\n", "", ParagraphLines),
    render_paragraphs(ParagraphLines, HtmlParagraphs),
    sub_string(Blog, 11, _, 3, H), get_blog_display_name(H, H0),
    phrase(page( [title(H0), \blog_style ], [ article(id(content), HtmlParagraphs) ] ), Tokens),
    print_html(Tokens).

get_blog_display_name(Blog, Path) :-
    re_replace("_" /g , " ", Blog, Path0),
    re_replace("-" /g , " ", Path0, Path1),
    re_replace("\\.pl" /g , "", Path1, Path).
    %string_upper(Path1, Path).

read_blog_files(Path, Paragraphs) :-
    consult(Path),
    findall(P, content(P), Paragraphs).

file_info(Path, Size, Modified) :-
    size_file(Path, Size),
    time_file(Path, Modified).

format_timestamp(Stamp, Time) :-
    stamp_date_time(Stamp, DT, 'UTC'),
    format_time(string(Time), '%Y-%m-%d %H:%M:%S', DT).
