---
title: Identifier des opportunités de positionnement avec R et Yooda Insight
title_seo: "Trouver des mots-clés SEO avec R et Yooda Insight"
description: "Découvrez dans ce petit tutoriel comment identifier les mots-clés travaillés par vos concurrents avec le logiciel R et Yooda Singiht."
date: 2017-12-04 17:18:42 +0100
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: Rechercher des mots-clés est une tâche récurrente en SEO, qui nécessite souvent de manipuler de gros volumes de données. Cela peut vite devenir très chronophage si on n'automatise pas un minimum. Si j'avais jusqu'ici l'habitude d'utiliser MySQL pour effectuer des traitements sur des fichiers de mots-clés volumineux, je me tourne désormais de plus en en plus vers R.
author:
slug: /opportunites-mots-cles-r
---

Voici un exemple de script qui va me permettre de résoudre une problématique récurrente, notamment lorsqu'on mène un audit concurrentiel : quels sont les mots-clés sur lesquels un ou plusieurs de mes concurrents sont présents dans les SERP, mais pas moi ?
Pour cet exemple, j'ai utilisé l'outil Yooda Insight, mais un outil comme SEMrush aurait fait l'affaire également.

## Récupérer la liste des mots-clés sur lesquels se positionnent mes concurrents

Pour chaque site étudié, je fais un export CSV du rapport "Expressions de recherche" de Yooda Insight.
Je fais la même chose pour mon site (ou celui de mon client), mais je renomme le fichier, par exemple en mon-site.csv, pour le distinguer des autres par la suite.
Je place l'ensemble fichiers dans le working directory utilisé avec R (ou R Studio, selon ce que vous préférez).

## La librairie incontournable : dplyr

Pour ce script, j'utilise la librairie `dplyr`, qui permet de réaliser des jointures, des déduplications, des tris et d'autres oéprations du genre, un peu à la manière de SQL.

``` r
library(dplyr)
```

## Concaténer les fichiers des concurrents avec R

Je stocke tout d'abord la liste des fichiers de mots-clés des concurrents. Ces fichiers ont comme point commun de commencer par "Seo" et de finir par ".csv".

``` r
files <- list.files(pattern = "Seo.*\\.csv$")
```

Puis j'ouvre chaque fichier pour en extraire le contenu. Pour cela, j'utilise la fonction `lapply`, en bouclant sur chaque élément de la liste. L'objectif étant de retourner une nouvelle liste, mais en ayant extrait le contenu des fichiers CSV.

``` r
competitors <- lapply(files,function(i){
  read.csv(i, check.names=FALSE, header=TRUE, sep=";", quote="\"")
})
```

Je concatène les données pour avoir un data frame contenant l'ensemble des éléments.

``` r
data <- do.call(rbind, competitors)
```

Je personnalise le nom des colonnes du data frame, via la fonction `names`.

``` r
names(data) <- c("Keyword","Trafic","Rank","Page","Volume","Concurrence","CPC","Results")
```

## Créer un data frame à partir de ses propres données

Pour le fichier de mots-clés de mon site, je procède de la même façon : création d'un data frame et renommage des colonnes.

``` r
my_data <- read.csv("mon-site.csv", check.names=FALSE, header=TRUE, sep=";", quote="\"")
names(my_data) <- c("Keyword","Trafic","Rank","Page","Volume","Concurrence","CPC","Results")
```

## Filtrer le data frame

Ensuite, je réduis le data frame aux deux colonnes qui m'intéressent : mot-clé et volume de recherche, soit la colonne 1 et la colonne 5.

``` r
competitor_keywords <- data[,c(1,5)]
```

Je déduplique (via la fonction `unique` de dplyr).

``` r
competitor_keywords <- unique(competitor_keywords)
```

Puis, à l'aide de `filter`, je sélectionne dans le data frame les lignes pour lesquelles la valeur du champ Keyword ne correspond pas à l'expression régulière contenue dans `!grepl`. En gros, j'élimine les mots-clés marque pour ne pas fausser l'analyse.

``` r
competitor_keywords <- filter(competitor_keywords, !grepl(".*(mot-clé-marque-1|mot-clé-marque-2).*",competitor_keywords$Keyword))
```

Je fais la même chose avec mon data frame.

``` r
my_keywords <- my_data[,c(1,5)]
my_keywords <- filter(my_keywords, !grepl("ma marque",my_keywords$Keyword))
```

## Dernière étape : l'anti join

Il ne reste plus qu'à réaliser un anti join, c'est-à-dire sélectionner dans le data frame des concurrents les mots-clés qui n'ont aucun "match" dans mon data frame. Un peu comme un left outer join en SQL, avec un select sur les valeurs null.

``` r
opportunities <- anti_join(competitor_keywords, my_keywords, by="Keyword")
```

Je peux enfin, en utilisant `arrange`, trier les mots-clés par ordre de volume de recherche afin d'afficher les opportunités de positionnement prioritaires, puis enregistrer le tout dans un CSV.

``` r
opportunities <- arrange(opportunities, desc(Volume))
write.csv(opportunities,"opportunities.csv")
```

Voici ce que l'on obtient, par exemple ici avec un client dans le domaine du tricot.

``` r
head(opportunities)
             Keyword Volume
1             alaska  33100
2           broderie   9900
3              teddy   6600
4               fils   5400
5 machine à tricoter   3600
6        blog tricot   3600
```

Et voilà, encore un bel exemple de traitement SEO avec R :)