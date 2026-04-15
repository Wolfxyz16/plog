% Copyright © 2025 Zhongying Qiao
% Licensed under the Apache License 2.0.
% See the LICENSE file for details or http://www.apache.org/licenses/LICENSE-2.0.

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(uri)).
:- use_module(library(pcre)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_header)).

:- use_module(build).

:- http_handler(root(.), home_handler, []).
:- http_handler(root(blogs), blog_handler, []).
:- http_handler(root('rss.xml'), rss_handler, []).
:- http_handler(images(.), image_handler, [prefix]).
:- http_handler(contents(.), content_handler, [prefix]).

home_handler(Request) :-
  http_reply_file('./public/index.html', [], Request).

blog_handler(Request) :-
  http_parameters(Request, [name(Blog, [])]),
  format(atom(PostPath), "./public/posts/~w.html", [Blog]),
  http_reply_file(PostPath, [], Request).

image_handler(Request) :-
    http_reply_from_files('images', [], Request).
content_handler(Request) :-
    http_reply_from_files('contents', [], Request).

% TODO fix the rss handler and generator
% rss generation remain generated on the go, should be generated in a static xml and stored in public directory
rss_handler(_) :-
    generate_rss(XML),
    format('Content-type: application/rss+xml~n~n'),
    format('~w', [XML]).

:- multifile http:location/3.
http:location(images, root(images), []).
:- multifile http:location/3.
http:location(contents, root(contents), []).

:- multifile user:file_search_path/2.
user:file_search_path(images, 'images').
:- multifile user:file_search_path/2.
user:file_search_path(contents, 'contents').

server(Port) :-
    generate_public,
    http_server(http_dispatch, [port(Port)]),
    thread_get_message(never).

site_title('Yeray Li Loaiza').
site_link('https://yerayliloaiza.cc').
site_description('My own personal web, written in pure prolog :)').

generate_rss(XML) :-
    site_title(Title),
    site_link(Root),
    site_description(Desc),
    atomic_list_concat([Root, '/rss.xml'], FeedURL),

    expand_file_name('./contents/*', FilesPaths),
    % predsort(compare_by_published_desc, FilesPaths, Sorted),

    findall(Item,
        ( member(Blog, FilesPaths),
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
    http_link_to_id(blog_handler, [name=BlogFile], RelLink),
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

get_blog_display_name(Blog, Path) :-
    re_replace("_" /g , " ", Blog, Path0),
    re_replace("-" /g , " ", Path0, Path1),
    re_replace("\\.pl" /g , "", Path1, Path).

file_info(Path, Size, Modified) :-
    size_file(Path, Size),
    time_file(Path, Modified).
