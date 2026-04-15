content("![landscape in Arrigunaga](/images/arrigunaga.webp)

# Another update comes to Plog today!

Well, this update focus more on the backend. There is a big change. Plog is not longer a dynamic html generator and server. Instead, now it generates all the static content using the `build.pl` and the `md_parser.pl`. After generating the html files and placing them inside the `public` directory, the `main.pl` is the http server that replies all the petitions with the pre-generated html files. This should be consider a big progress.

After these changes, I would like to focus more on building an website framework based on logic programming. Users should be able to easily edit their landpage and run the server with a simple command.

I do not like also the idea that the blogs must be written in an prolog file, so, the next update could be an markdown file reader implemented inside the `md_parser` module.

That's all I got to say.
").
