% Copyright © 2025 Zhongying Qiao
% Licensed under the Apache License 2.0.
% See the LICENSE file for details or http://www.apache.org/licenses/LICENSE-2.0.

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(uri)).
:- use_module(library(pcre)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_files)).
:- use_module(style).

:- http_handler(root(.), list_blogs, []).
:- http_handler(root(blogs), list_blog, []).
:- http_handler(root('rss.xml'), rss_handler, []).

:- multifile http:location/3.
http:location(images, root(images), []).
:- multifile http:location/3.
http:location(contents, root(contents), []).

:- multifile user:file_search_path/2.
user:file_search_path(images, 'images').
:- multifile user:file_search_path/2.
user:file_search_path(contents, 'contents').

:- http_handler(images(.), image_handler, [prefix]).
:- http_handler(contents(.), content_handler, [prefix]).

image_handler(Request) :-
    http_reply_from_files('images', [], Request).
content_handler(Request) :-
    http_reply_from_files('contents', [], Request).

rss_handler(_) :-
    generate_rss(XML),
    format('Content-type: application/rss+xml~n~n'),
    format('~w', [XML]).

content_files(Files) :-
    absolute_file_name(contents, Dir, [ file_type(directory), access(read)]),
    directory_files(Dir, Raw),
    exclude(is_dot, Raw, Files).
is_dot('.').
is_dot('..').

file_info(File, Size, Modified) :-
    format(string(Path), "contents/~w", [File]),
    size_file(Path, Size),
    time_file(Path, Modified).

format_timestamp(Stamp, Time) :-
    stamp_date_time(Stamp, DT, 'UTC'),
    format_time(string(Time), '%Y-%m-%d %H:%M:%S', DT).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    thread_get_message(never).

list_blogs(_Request) :-
    content_files(Files),
    predsort(compare_by_published_desc, Files, Sorted),
    reply_html_page(
    title('Yeray Li Loaiza'),
        [ \page_style ],
        [
            main([id(content)], [
                h1('Yeray Li Loaiza'),
		h3('AI Developer and software libre enthusiast'),
                section([id(meta)], [
		    p('Welcome to my personal web page. Here you will find the projects I am currently working on and you can read about my opinion in different topics. Take a seat and enjoy!'),
		    img([src('/images/profile.jpg'), width(416), height(624), alt('picture of me in Shanghai!')]),
		    p(a([href('https://github.com/cryptoque/prolog-blog-engine'), target('_blank')], 'This blog has been created using this awesome project!'))
                ]),

                table(
                    [
                        \header|
                        \blogs(Sorted)
                    ]
                )
            ])
        ]
    ).

header --> 
    html(tr([   th([class(title)], 'Title'), th([class(desc)],  ''), th([class(time)], 'Last Updated At')])).

blogs([]) --> [].
blogs([H|T]) --> 
    {get_blog_display_name(H, H0)},
    html(tr([td([class(title)], \blog_link(H0, H)), td([class(desc)], ''), td([class(time)], \get_published_at(H))])),
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
    { http_link_to_id(list_blog, [name=Display], HREF) },
    html(a(href(HREF), Blog)).

list_blog(Request) :-
    http_parameters(Request, [name(Blog, [])]),
    read_blog_files(Blog, Paragraphs),
    [Innerparagraphs] = Paragraphs,
    split_string(Innerparagraphs, "\n", "", ParagraphLines),
    render_paragraphs(ParagraphLines, HtmlParagraphs),
    reply_html_page(
        title('Title: ~w'-[Blog]),
        [ \blog_style ],
        [ 
          div(id(content), HtmlParagraphs)
        ]
    ).

render_paragraphs([], []).
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
        append(PBefore, [b(M)|PAfter], Parts);
    
        re_matchsub("^(.*?)_(.*?)_(.*)$", Line, D, []) ->
        B = D.get(1),
        M = D.get(2),
        A = D.get(3),
        inline(B, PBefore),
        inline(A, PAfter),
        append(PBefore, [i(M)|PAfter], Parts);
        
        Parts = [Line]
    ).

get_blog_display_name(Blog, Path) :-
    re_replace("_" /g , " ", Blog, Path0),
    re_replace(".pl" /g , "", Path0, Path).
    %string_upper(Path1, Path).

read_blog_files(Blog, Paragraphs) :-
    format(string(Path), "contents/~w", [Blog]),
    consult(Path),
    findall(P, content(P), Paragraphs).

site_title('Yeray Li Loaiza web').
site_link('https://yerayliloaiza.me').
site_description('My own personal web, written in pure prolog.').

generate_rss(XML) :-
    site_title(Title),
    site_link(Root),
    site_description(Desc),
    atomic_list_concat([Root, '/rss.xml'], FeedURL),

    content_files(Files),
    predsort(compare_by_published_desc, Files, Sorted),

    findall(Item,
        ( member(Blog, Sorted),
          rss_item(Blog, Item)
        ),
        Items),

    atomic_list_concat(Items, "\n", ItemsXML),

    format(string(XML),
'<?xml version=\'1.0\' encoding=\'ISO-8859-1\'?>
<rss version=\'2.0\' xmlns:atom=\'http://www.w3.org/2005/Atom\'>
<channel>
<title>~w</title>
<link>~w</link>
<description>~w</description>
<atom:link href=\'~w\' rel=\'self\' type=\'application/rss+xml\' />
~w
</channel>
</rss>',
    [Title, Root, Desc, FeedURL, ItemsXML]).


rss_date(Timestamp, RSS) :-
    stamp_date_time(Timestamp, DT, 'UTC'),
    format_time(string(RSS),
        '%a, %d %b %Y %H:%M:%S GMT', DT).

rss_item(BlogFile, XML) :-
    get_blog_display_name(BlogFile, Display),
    file_info(BlogFile, _, Created),
    rss_date(Created, PubDate),
    http_link_to_id(list_blog, [name=BlogFile], RelLink),
    site_link(Root),
    uri_resolve(RelLink, Root, Link),
    format(string(XML),
'<item>
<title>~w</title>
<link>~w</link>
<pubDate>~w</pubDate>
<guid isPermaLink="true">~w</guid>
</item>',
    [Display, Link, PubDate, Link]).
