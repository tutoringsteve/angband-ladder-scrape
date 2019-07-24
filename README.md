# angband-ladder-scrape
Scraping the Angband ladder and analyzing it with R.

Angband is a classic game, predating modern graphics. It presents dungeons using "ascii" or text based graphics. The theme is lord of the rings. It is a turn based RPG with a lot of depth. My mother taught me to play when I was young. I had played the game for nearly two decades before finally beating the game and submitting a character to the website, where my character sits on a "ladder" or ranking system. 

When I was learning R I thought it would be interesting to scrape the ladder data in R, transform it into a data frame using R, and then analyze the data (hopefully in interesting ways) in R. 

Therefore, this project is broken up into three components.

<b>1.</b> I ***scrape*** the <http://angband.oook.cz/ladder.php> website for Angband characters (there are many variants but I scrape only characters on the ladder that uploaded to "vanilla" Angband.) The scrape is found in the script named ***angScrape.r***.

<b>2.</b> I ***clean*** the data using R. The cleaning portion of this process is found in the script named ***angClean.r***.

<b>3.</b> I ***analyze*** the data using R. I do this in an RMarkDown .RMD file which compiles into a .html file so that I can interweave commentary and code, presenting the information in a way that can be read on any web browser. The uncompiled RMarkDown file is called ***preview.Rmd*** and the html file it generates is called ***preview.html***.
