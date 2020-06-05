# Redditly
Swift News Subreddit Sample Project

This sample project employs the Reddit JSON API on the /r/swift subreddit (although technically any subreddit could be used). The interface is somewhat simplified having been built quickly, instead focusing on architecture and code readability. Plus played around with a few concepts with generics, protocols, Result types, and key paths.

Used one Cocoapod, MarkdownKit, because Reddit post bodies may contain Markdown and it was impractical to re-engineer.

Some areas of improvement: 
* error handling (article download, image download failure)
* loading indicators especially for slow networks
* improve UI
* endless loading of additional articles when scroll to bottom of main list
* Testing / tesability: could modify ApiManager to be more abstracted and thus more testable, load some test data into the project and write some unit / UI tests.
