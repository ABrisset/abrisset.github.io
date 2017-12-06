---
title: "Mots-clés de contenu Google Webmaster Tools : sur quel contenu porte l'analyse ?"
title_seo: "Webmaster tools : mots clés de contenu, le test"
description: "Comment Google calcule-t-il le nombre d'occurences des mots-clés dans Google Webmaster Tools ? Quelques hypothèses et réflexions pour mieux comprendre l'analyse lexicale."
date: 2013-12-24
hero_image: semantic.jpg
thumbnail:
category: "Sémantique"
excerpt: "Si vous possédez un compte Webmaster Tools et que vous y avez inscrit vos sites, vous avez peut être déjà remarqué l'onglet 'Mots-clés de contenu' dans la section 'Index Google'. La <a href='https://support.google.com/webmasters/answer/35255?hl=fr'>documentation officielle</a> précise qu'il s'agit là d'un échantillon des mots-clés les plus représentatifs trouvés par Google lors de l'exploration du site. Mais savez-vous comment Google s'y prend pour calculer le nombre d'occurences ? Je vous donne ici ma vision des faits. Il ne s'agit que d'une interprétation personnelle, je ne prétends pas vous donner une vérité, d'ailleurs vous le verrez, j'arrive difficilement à une conclusion solide"
author:
slug: /mots-cles-webmaster-tools
---

## N-gram & stem

Pour aboutir aux chiffres qui sont donnés dans les Outils aux Webmasters, on peut imaginer que Google agit, grosso modo, en plusieurs étapes :

1. lors du crawl, Googlebot récupère le contenu textuel de chaque page du site

2. un corpus est donc formé à partir de cet agrégat de contenus

3. les chaînes de caractères du corpus sont découpées en séquences : points, retours à la ligne, virgules et autres signes de ponctuation permettant d'identifier deux séquences de mots distinctes

4. les stop words de ces séquences sont éliminés pour réduire le bruit

5. ces séquences de mots sont stockées puis converties en n-grammes de 1 mot dont Google calcule le nombre d'apparitions sur l'ensemble du corpus. En effet, dans la console Webmaster Tools, il s'agit toujours de chaînes de caractères constituées d'un seul mot

6. Google opère une stemmatisation afin de regrouper les chaînes de caractères partageant la même racine et recalcule le nombre d'occurences de chaque mot attaché à ce "stem"

Toute la difficulté consiste maintenant à savoir sur quels éléments de la page Google se base pour effectuer cette analyse (cf phase 1)

**Prend il en compte les attributs alt, les balises meta descriptions, les balises title ? Se limite-t-il au body, ou prend-il également en compte le head ?**


## Quels pourraient être les éléments de la page servant à l'analyse ?

Afin d'apporter un début de réponse à cette question, je vais prendre en exemple mon [petit site de téléchargement Keewa.net](http://www.keewa.net).
Dans mon compte Google Webmaster Tools, dans l'onglet "Mots-clés de contenu", voici les données que Google me donne :

![Search Console](/images/posts/gwt_1.png "Search Console")

Nous allons donc comparer ces données avec celles issues d'une petite moulinette Ruby perso effectuant le travail suivant :

* scraper le contenu de chacune des pages du site

* stocker le tout

* sortir les unigrammes, avec le nombre d'occurences associé

Avec quelques gems bien pratiques, j'ai testé et confronté entre elles plusieurs configurations.

### 1er cas : xpath du scraping = //text()

Dans le 1er cas, le xpath utilisé lors du scrape est :

``` ruby
"//text()"
```

Sont donc pris en compte donc les noeuds texte du DOM, sauf les éléments suivants que j'ai volontairement **ignorés** :

* les balises script

* les commentaires html

* les balises noscript

* les balises style

* les attributs alt

* toutes les meta *sauf la title*

Voici le top 10 que j'obtiens avec ce premier paramétrage, **[stopwords](http://www.naunaute.com/liste-stop-words-francais-393) exclus**. A titre de comparaison, dans la troisième colonne, j'ai ajouté le nombre d'occurences donné par Google dans la console GWT.

|- String -                   |- Script -|-  GWT  -|-  Comparaison  -|
|:----------------------------| :------: | :-----: | :-------------: |
| keewa                       | 30       | 30      | =
| google                      | 23       | 26      | !=
| télécharger/téléchargement  | 24       | 24      | =
| série/séries	              | 17       | 17      | =
| film/films                  | 18       | 16      | !=
| recherche/recherchez        | 15       | 14      | !=
| net	                        | 12       | 11      | !=
| facebook	                  | 10       | 10      | =
| google+                     | 10       | 10      | =
| résultat/résultats          | 11       | 10      | !=
<br />
A noter que Google a "mergé" le nombre d'occurences des mots-clés de même racine :

* "téléchargement" et "télécharger" ont un nombre d'occurences cumulé de 24 selon Google. Si j'additionne les occurences de ces deux mots, de mon côté, j'obtiens également 12 + 12 = 24 :)

* "film" et "films" ont un nombre d'occurences cumulé de 16 selon Google. Si j'additionne les occurences de ces deux mots, de mon côté, j'obtiens 15 + 3 = 18 :(

* "série" et "séries" apparaissent 17 fois d'après Google. Pour ma part, j'ai 12 occurences pour "série" et 5 pour "séries", soit 17 aussi :)

* "résultat" et "résultats" sont relevés 10 fois par Google. Pour ma part, j'ai 8 occurences pour "résultats" et 3 pour "résultat", soit 11 occurences au total :(

Au final, je retrouve le même nombre d'occurences que Google dans 5 cas sur 10.
Cette méthode d'analyse me donne donc, sur cet échantillon, un matching de **50%**.
En valeur absolue, le différentiel est de 8.


### 2ème cas : xpath du scraping = //text() + //img/@alt

Dans le 2ème cas, le xpath utilisé est

``` ruby
"//text()|//img/@alt"
```

Sont donc pris en compte les attributs alt des images, la balise title et tous les noeuds texte du DOM, sauf les éléments suivants que j'ai volontairement **ignorés** :

* les balises script

* les commentaires html

* les balises noscript

* les balises style

* les attributs alt

* toutes les meta


Voici ce que cela donne :

|- String -                   |- Script -|-  GWT  -|-  Comparaison  -|
|:----------------------------| :------: | :-----: | :-------------: |
| keewa                       | 31       | 30      | !=
| google                      | 25       | 26      | !=
| télécharger/téléchargement  | 24       | 24      | =
| série/séries	              | 19       | 17      | !=
| film/films                  | 18       | 16      | !=
| recherche/recherchez        | 17       | 14      | !=
| net	                        | 12       | 11      | !=
| facebook	                  | 10       | 10      | =
| google+                     | 10       | 10      | =
| résultat/résultats          | 12       | 10      | !=
<br/ >
Comme on peut le voir dans le tableau, je retrouve les mêmes résultats que Google dans 3 cas sur 10, soit **30%** de réussite.
En valeur absolue, un différentiel de 12.


### Dernier cas : xpath du scraping = //text() + //meta[@name="description"]/@content

Testons un dernier cas, en prenant en compte cette fois la meta description. Le xpath est donc

``` ruby
"//text()|//meta[@name=\"description\"]/@content"
```

Sont donc pris en compte la balise title, la balise meta description et tous les noeuds texte du DOM, sauf les éléments suivants que j'ai volontairement **ignorés** :

* les balises script

* les commentaires html

* les balises noscript

* les balises style

* les attributs alt

* toutes les autres meta

Voici ce qu'on obtient :

|- String -                   |- Script -|-  GWT  -|-  Comparaison  -|
|:----------------------------| :------: | :-----: | :-------------: |
| keewa                       | 36       | 30      | !=
| google                      | 25       | 26      | !=
| télécharger/téléchargement  | 29       | 24      | !=
| série/séries	              | 19       | 17      | !=
| film/films                  | 20       | 16      | !=
| recherche/recherchez        | 17       | 14      | !=
| net	                        | 15       | 11      | !=
| facebook	                  | 10       | 10      | =
| google+                     | 10       | 10      | =
| résultat/résultats          | 11       | 10      | !=
<br />
Le matching est donc de **20%**, avec une différence, en valeur absolue, de 26. Avec cette configuration, les résultats sont très éloignés de ceux de Google.


## Conclusion

Pour cette analyse, certes, le jeu de test est vraiment réduit : 1 site, 5 pages, un échantillon de 9 mots-clés. Néanmoins, l'hypothèse la plus probable si on se fie à ces données est que les résultats affichés dans "Mots-clés de contenu" sont issus d'une analyse du texte des pages correspondant au premier cas de texte, c'est-à-dire :

* les balises title

* tous les noeuds "texte" de la page sauf les balises script/noscript, les commentaires, les balises styles

Les balises meta et les textes alternatifs trouvés dans la page seraient eux écartés de l'analyse.

Cette conclusion est donc au *conditionnel*, mais l'analyse a le mérite de poser certaines questions : les données de "Mots-clés de contenu" sont-elles fiables à 100% ? Les balises meta entrent elles dans le champ d'analyse ? A fortiori, est-ce un indice montrant que ces balises ne servent à rien dans le ranking ?

Si vous avez réalisé des tests similaires pour comprendre un peu mieux ce rapport Google Webmaster Tools, n'hésitez pas à le signaler en commentaire ;)
