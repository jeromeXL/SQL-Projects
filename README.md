# SQL-Projects

# Beers 

In order to work with a database, it is useful to have some background in the domain of data being stored. Here is a very quick tour of beer. If you want to know more, see the Wikipedia Beer Portal.

Beer is a fermented drink based on grain, yeast, hops and water. The grain is typically malted barley, but wide variety of other grains (e.g. oats, rye) can be used. There are a wide variety of beers, differing in the grains used, the yeast strain, and the hops. More highly roasted grains produce darker beers, different types of yeast produce different flavour profiles, and hops provide aroma and bitterness. To add even more variety, adjuncts (e.g. sugar, chocolate, flowers, pine needles, to name but a few) can be added.

To build a database on beer, we need to consider:

beer styles (e.g. lager, IPA, stout, etc., etc.)
ingredients (e.g. varieties of hops and grains, and adjuncts)
breweries, the facilities where beers are brewed
beers, specific recipes following a style, and made in a particular brewery
Specific properties that we want to consider:

ABV = alcohol by volume, a measure of a beer's strength
IBU = international bitterness units
each beer style has a range of ABVs for beers in that style
for each beer, we would like to store
its name (brewers like to use bizarre or pun-based names for their beers)
its style, actual ABV, actual IBU (optional), year it was brewed
type and size of containers it's sold in (e.g. 375mL can)
its ingredients (usually a partial list because brewers don't want to reveal too much)
for each brewery, we would like to store
its name, its location, the year it was founded, its website
The schema is described in more detail both as an ER model and an SQL schema in the schema page.
