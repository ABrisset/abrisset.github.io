---
title: Analyser les title d'une requête avec R
title_seo: "Scraping & Analyse de Balise Title avec R"
description: "Apprenez à scraper avec R et à calculer les fréquences de n-grams dans un corpus, en seulement quelques lignes de codes."
date: 2017-05-26 17:17:47 +0200
hero_image: semantic.jpg
thumbnail:
category: "Sémantique"
excerpt: "Le langage R a le vent en poupe dans la communauté SEO depuis quelques mois, voire quelques années. Après avoir lu les très bons articles de <a href='https://data-seo.fr/'>Vincent Terrasi</a> et de <a href='http://gameofseo.fr/'>Grégory Florin</a> sur le sujet, je me suis lancé il y a peu dans l'apprentissage de ce langage."
---

Les avantages de R, à mon sens, sont tout d'abord le nombre de librairies existantes, notamment pour faire du TAL, mais aussi et surtout la possibilité de produire une visualisation directement depuis la console, en quelques lignes. La complexité, je trouve, est de bien comprendre la différence entre les vecteurs, les data frames, les listes, les tableaux... et de les utiliser à bon escient en fonction de l'objectif.

Pour ce premier article sur R, je vais vous montrer comment extraire les balises title des 10 premiers résultats de la SERP, puis analyser les n-grams contenus dans ces balises. Let's go !

## Charger les librairies nécessaires

Commençons par charger les librairies dont nous aurons besoin :

* tm : pour les opérations de text mining
* corrplot : pour la visualisation de la matrice finale
* rJava : pour appeler du code Java depuis R
* rvest : pour le scraping
* RWeka : pour le calcul de n-grams

``` r
library(tm)
library(corrplot)
library(rJava)
library(rvest)
library(RWeka)
```

Si elles ne sont pas installées sur votre machine, vous pouvez le faire via install.packages("nom_librairie").

## Scraper les résultats Google

Pour scraper le contenu des pages HTML, j'utilise la library rvest qui contient tout un ensemble de fonctions permettant d'aller à l'essentiel.

Tout d'abord, je récupère le code HTML de la page de résultats. Ici, j'ai choisi la page de résultats Google pour la requête *consultant seo* :

``` r
source <- read_html("https://www.google.fr/search?q=consultant%20seo")
```

Via XPath, je récupère les liens et leurs contenus dans un vecteur :

``` r
links <- html_nodes(source, xpath="//h3[@class='r']/a/@href")
links <- html_text(links)
```

Je nettoie le vecteur, pour ne garder que les URL. Pour cela, j'utilise la fonction `sub` associée à une expression régulière :

``` r
pattern <- "\\/url\\?q=(.*)&sa.*"
links <- sub(pattern, '\\1', links, perl=TRUE)
links <- grep("http", links, fixed=TRUE, value=TRUE)
```

## Extraire les balises title

Via la fonction `get_title`, je récupère la balise title de chaque page et la stocke dans une liste :

``` r
data <- list()
get_title <- function(x) {
  html_text(html_nodes(read_html(x), xpath='//title'))
}
output <- sapply(links, get_title)
```

## Nettoyer les contenus

Passons maintenant à la phase de nettoyage des contenus. Je stocke tout d'abord la liste de balises title dans un corpus, puis j'applique un ensemble de traitements : suppression de la ponctuation (via une fonction personnalisée), suppression des caractères numériques, suppression des stopwords, changement de la casse (minuscule).

``` r
replacePunctuation <- content_transformer(function(x) {return (gsub("[[:punct:]]"," ", x))})

corpus <- VCorpus(VectorSource(output))
corpus <- tm_map(corpus, replacePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("french"))
corpus <- tm_map(corpus, content_transformer(tolower))
```

## Créer la matrice et visualiser les données

Une fois le corpus prêt, je transforme le corpus en "Term Document Matrix" : il s'agit d'une matrice présentant la fréquence des mots apparaissant dans le corpus de documents. Pour donner du sens à l'analyse, je transforme chaque suite de caractères en séquence de 2 mots (bi-grammes), grâce à la fonction `NGramTokenizer` :

``` r
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
tdm <- TermDocumentMatrix(corpus, control = list(tokenize = BigramTokenizer))
```

Je transforme la TDM en matrice "classique", puis je génère la visualisation :

``` r
m <- as.matrix(tdm)
corrplot(m, is.corr=FALSE)
```

![SSL](/images/posts/tdm.png "Term Document Matrix")

Il y aurait quelques optimisations à faire (suppression des accents, lemmatisation ou racinisation des mots, augmentation de la taille du corpus) mais le résultat est déjà très intéressant. On peut voir, par exemple, que dans 9 résultats sur 10 l'expression "consultant seo" est présente dans la balise title et que les mots-clés "expert seo" et "expert référencement" reviennent également fréquemment.


Voilà, à bientôt pour un nouvel article sur R !