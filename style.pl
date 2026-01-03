% Copyright © 2025 Zhongying Qiao
% Licensed under the Apache License 2.0.
% See the LICENSE file or http://www.apache.org/licenses/LICENSE-2.0.

:- module(style, [page_style//0, blog_style//0]).
:- use_module(library(http/html_write)).

page_style -->
    html(style(type('text/css'), "
        body {
            margin: 0;
            font-family: Cantarell, sans-serif;
            background: #fafafa;
        }

        #content {
            max-width: 60rem;
            margin: 3rem auto;
            padding: 0 1.5rem;
        }

        h1 {
            margin: 0 0 2rem 0;
            font-size: 2.5rem;
        }

        table.blog_index {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.95rem;
        }

        table.blog_index th,
        table.blog_index td {
            padding: 0.4rem 0.2rem;
        }

        table.blog_index thead th {
            border-bottom: 2px solid #222;
        }

        table.blog_index tbody tr:hover {
            background: #f0f0f0;
        }

        table.blog_index td.date {
            text-align: right;
            white-space: nowrap;
            padding-left: 1rem;
        }

        table.blog_index a {
            text-decoration: none;
            color: #2b3ebf;
        }

        table.blog_index a:hover {
            text-decoration: underline;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 2rem;
        }

        th {
            text-align: left;
            font-size: 0.85rem;
            color: #555;
            font-weight: 600;
            padding-bottom: 0.6rem;
        }

        td {
            padding: 0.45rem 0;
            vertical-align: top;
        }

        td.title a {
            font-size: 1rem;
            line-height: 1.4;
            text-decoration: none;
            font-family: 'Georgia', serif;
            font-weight: 500;
        }

        td.title a:hover {
            text-decoration: underline;
        }

        td.time {
            font-size: 0.8rem;
            color: #666;
            white-space: nowrap;
            min-width: 170px;
            font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
        }

        td.desc {
            font-family: 'Georgia', serif;
            font-size: 0.85rem;
            color: #777;
            line-height: 1.4;
            max-width: 420px;
            padding-left: 1.2rem;
            font-style: italic;
        }

        #meta {
            font-family: 'SF Mono','Menlo',monospace;
            font-size: 0.75rem;
            color: #777;
            margin-bottom: 1.5rem;
            max-width: 900px;
            line-height: 1.2;
        }

        #meta code {
            background: #f3f3f3;
            padding: 0 0.15rem;
            border-radius: 3px;
        }

        #meta a {
            color: #444;
            text-decoration: underline;
        }

        #meta a:hover {
            color: #000;
        }
    ")).

blog_style -->
    html(style("
        body {
            margin: 0;
            background: #fafafa;
            font-family: Georgia, serif;
            line-height: 1.55;
        }

        #content {
            max-width: 60rem;
            margin: 3rem auto;
            padding: 0 1.5rem;
        }

        img.cover {
            display: block;
            margin: 2rem auto;
            max-width: 100%;
            border-radius: 4px;
        }

        h1 {
            margin-bottom: 0.3rem;
            font-size: 2.3rem;
            line-height: 1.1;
        }

        h2 {
            margin-top: 2.4rem;
            font-size: 1.4rem;
        }

        a {
            color: #2b3ebf;
        }
    ")).
