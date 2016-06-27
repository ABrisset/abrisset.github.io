---
title: "Scraper facilement avec Ruby et Nokogiri"
title_seo: "Ruby : web scraping avec la gem Nokogiri"
description: "Ruby possède de sompteuses Gems pour le scraping de contenu. Voici une présentation de la Gem Nokogiri avec un exemple concret de scraping SEO."
date: 2013-04-15
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: "Le scraping est l'une des actions qui fait partie du quotidien d'un SEO. On peut s'en servir par exemple en phase d'audit pour extraire le contenu de certaines balises, en phase de netlinking pour extraire les résultats Google, etc. Je vais vous présenter ici un petit script ruby réalisé avec l'aide de <a href='https://twitter.com/__clement___'>@clement_</a>, et qui vous sera peut-être utile si vous n'avez pas sous la main un logiciel approprié. Vous pourrez l'exécuter directement en console et récupérer ainsi rapidement ce dont vous avez besoin."
author:
---

## 1ère étape : récupérer uniquement les données utiles du CSV

Tout d'abord, nous devons installer la gem "nokogiri" qui permet de parser et de scraper des documents en s'appuyant sur des sélecteurs CSS ou des expressions XPath. Nous avons également besoin de la librairie "open-uri" et de la libraire "CSV", qui sont toutes deux des librairies standards de ruby.

``` ruby
#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'CSV'
```

Nous récupérons dans un premier temps le contenu du CSV dans un array à l'aide de la classe CSV et de la méthode read, en spécifiant le chemin du fichier ainsi que le délimiteur utilisé, par exemple ici le point virgule.

``` ruby
array_of_arrays = CSV.read("./urls.csv", {col_sep: ";"})
```

Il faut ensuite écrire la méthode qui permet de ne récupérer que le premier élément de chaque array de l'array global récupéré précédemment. Autrement dit, uniquement la première cellule de chaque ligne de notre CSV si notre CSV comporte plusieurs colonnes.

Pour cela, nous utilisons la méthode reduce. La méthode reduce permet, à partir d'un array, de retourner une valeur unique ou un array. Nous allons dans un premier temps "passer" à reduce un tableau vide en valeur initiale ([]). Puis initier la boucle.

``` ruby
array.reduce([]) do |result, elem|
```

A chaque passe, donc sur chaque élément de l'array (elem), la valeur totale est incrémentée (result). Maintenant que nous avons découpé notre array, il ne reste plus qu'à demander à ruby de stocker dans "result" la première valeur de chaque "elem", c'est-à-dire la première cellule de chaque ligne du fichier de base.

``` ruby
result << elem.first
```

Ce qui donne :

``` ruby
def select_first_array_elem(array)
  array.reduce([]) do |result, elem|
    result << elem.first
  end
end
```

## 2ème étape : scraper sur la liste d'URLs

Il faut ensuite définir la méthode qui permet de récupérer les données recherchées dans le document HTML. C'est là qu'entre en scène [Nokogiri](http://nokogiri.org/). Dans un premier temps, nous allons récupérer le contenu du document dans une variable.

``` ruby
def analyse_url(url)
  data = Nokogiri::HTML(open(url))
```

Puis à partir de cette variable, récupérer le contenu du noeud qui nous intéresse. Par exemple, la balise title.

``` ruby
title = data.xpath("//title").text
```

Et enfin, retourner le résultat. Ce qui donne donc :

``` ruby
def analyse_url(url)
  data  = Nokogiri::HTML(open(url))
  title = data.xpath("//title").text
  title
end
```

## 3ème étape : boucler sur chaque url

Une fois la méthode de scrape définie, il faut définir la méthode qui permet de boucler sur chaque élément de l'array obtenu en 1. Nous déclarons une variable "result", avec array vide. Puis nous lançons la boucle (.each do). Chaque élément "url" de la boucle devient un argument de la fonction de scrape précédente et l'ensemble est stocké dans "result".

``` ruby
def scraping_each_url(array)
  result = []
  array.each do |url|
    result << analyse_url(url)
  end
  result
end
```

## Dernière étape : afficher les données récupérées

Il ne reste plus qu'à afficher les données pour chaque url. Pour cela rien de plus simple.On apelle les méthodes que l'on a définies.

``` ruby
array1  = select_first_array_elem(array_of_arrays)
results = scraping_each_url(array1)
```

Puis on affiche le résultat en console.

``` ruby
puts "#{results}"
```

Bien entendu, l'idéal est d'enregistrer le résultat dans un nouveau fichier CSV en sortie.Là non plus rien de sorcier et je vous laisse vous reporter à la [doc ruby](http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html#label-Writing) pour finir le travail ;)
