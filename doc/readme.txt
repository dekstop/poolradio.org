martind 2008-05-04, 13:05:40

 ================
 = requirements =
 ================

- mysql
- ruby with gems: mysql, sequel, hpricot
- php


 ============================
 = last.fm feature requests =
 ============================

- user manualrecs feed does not seem to contain all recommendations -- e.g. for listen pages.
- forum feeds are a bit basic
  - feed entries just link to a page, there is no text
  - each forum only has a feed with links to threads, there is no feed to get recent posts (or recent posts within a thread)
  -> we need to scrape forum pages (which btw have great semantic markup!)
- forum page semantic markup is great! minor nitpicks:
  - extracting pagination information requires parsing of language-specific text:
    <div class="pagination"><span class="pages">Page 2 of 2</span> ...