The project was originally inspired by the multiboards.net project (sam & max). The feature I felt missing being of course not being allowed to chose which RSS feeds to follow.

___________________________________________________________________________________

What SlackeRss is :
-------------------

* A minimalist client-side RSS reader. It just gives you a snapshot of the last news for each of your websites (feed). Saved feeds are stored directly in the browser using localStorage.

What it isn't :
--------------

* A non-minimalist RSS reader : SlackeRss won't come after you with a list of still-not-read news.

* A database-based application : your feeds are stored IN YOUR BROWSER. Go to SlakeRss from another computer, be told that you won't find your saved feeds waiting for you.
_____________________________________________________________________________________

Get started :
-------------

Click New Feed at the top right of the page, it will open a new panel.
From here, you are given a link called SlackIt. Saved as a bookmark in any modern browser, it will allow you to just click it, when browsing on a beloved news site, to add it's RSS-feed to SlackeRss.

To save SlackIt as a bookmark :
* Firefox : right-click -> 'Bookmark this link'
* Chrom(ium) : right-click -> 'copy link location'
                    menu -> 'Bookmarks' -> 'New' -> 'link' = YourCopiedLink

______________________________________________________________________________________

Installation :
--------------

Just clone the github repository and put it in your http server. That's it. No database needed, no php, no configuration or anything. Just be told that SlakeRss won't run from a local file due to cross-domain policies. You will need a http server.

Libs :
    backbone.js
    backbone.localStorage.js
    underscore.js
    coffee-script.js
    jquery.js
    bootstrap.css
    bootstrap.responsive.css