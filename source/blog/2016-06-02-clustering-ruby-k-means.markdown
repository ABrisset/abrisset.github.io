---
title: "Clustering de mots-clés : un exemple avec K-means & Ruby"
title_seo: "Clustering de mots-clés : utilisation de l'algorithme K-means"
description: "Découvrez comment créer des clusters de mots-clés en utilisant l'algorithme K-means couplé à quelques lignes de Ruby !"
date: 2016-06-02 15:45:00 +0200
hero_image: semantic.jpg
thumbnail:
category: Sémantique
excerpt: "Le machine learning étant un des nouveaux sujets SEO du moment, j'ai récemment commencé à approfondir le sujet et à mettre les mains dans le cambouis, dans le cadre d'une problématique bien précise : la catégorisation de mots-clés."
author:
---

En ce moment, ma veille et mes recherches portent sur la manière de clusteriser un ensemble de mots-clés. En effet, le problème, lorsqu'on réalise une étude de mots-clés, ce n'est pas de trouver les expressions, puisque de nombreux outils existent pour nous aider dans cette tâche (SEMrush, Keywordtool.io, etc.). Toute la difficulté consiste plutôt à les regrouper pour créer des ensembles cohérents, qui nous guideront soit dans la création de campagnes Adwords, soit dans l'ébauche d'une arborescence ou d'un plan éditorial. En creusant un peu, je suis tombé sur l'algorithme *K-means* (*K-moyennes* en français), qui constitue un bon début. Voyons comment l'utiliser avec Ruby.

## Qu'est-ce que K-means ?

K-means est un algorithme de partitionnement de données qui repose sur [un apprentissage non supervisé](https://fr.wikipedia.org/wiki/Apprentissage_non_supervis%C3%A9).

### 1ère étape
A partir d'un jeu de données qu'on transforme en points, et d'un nombre k de partitions défini au préalable, on calcule la distance entre chacun des points du dataset et chacun des k *centroids* choisis aléatoirement. Chacun des points est ensuite assigné au centroid le plus proche, ou, plus précisément, au centroid avec lequel **la distance euclidienne est la plus faible**. Bien entendu, la mesure de distance peut varier : similarité cosinus, indice de Jaccard, etc.

### 2ème étape
Suite à cela, deuxième passe, on calcule la moyenne des points appartenant à chaque centroid et on déplace le centroid en fonction de la moyenne obtenue.
Puis on recommence la 1ère étape, et ainsi de suite de manière itérative jusqu'à ce que les clusters soient stables.

Pour bien comprendre, je vous conseille [cette vidéo](https://www.youtube.com/watch?v=_aWzGGNrcic).


## Implémentation en Ruby
### 1. Installez la gem "kmeans-clusterer"

Comme toujours en Ruby, il existe des gems qui vont nous faciliter le travail. Ici, nous utiliserons la gem [KMeansClusterer](https://github.com/gbuesing/kmeans-clusterer).
Ajoutez-la à votre Gemfile, installez-la via Bundler et n'oubliez pas de l'inclure dans votre fichier.

``` ruby
#!/usr/bin/env ruby

require 'kmeans-clusterer'
```

### 2. Transformez votre set de mots-clés en vecteurs

Pour pouvoir utiliser nos données dans le programme, il va falloir d'abord convertir nos mots-clés en vecteurs, stockés dans un array global.
Prenons l'exemple d'un set réduit de mots-clés autour du SEO. On commence par stocker nos mots-clés dans un array.

``` ruby
keywords = ["consultant seo","référencement naturel","expert seo","referencement naturel","consultant referencement","consultant référencement","agence de référencement","agence seo","consultant en référencement","expert referencement","agence référencement","consultant référencement naturel","agence referencement","consultant en referencement","agence de referencement","référencement seo","experts referencement","référenceur freelance","consultant référencement internet","expert référencement","consultant referencement naturel","consultant en référencement naturel","conseil seo","referenceur freelance","spécialiste référencement naturel","search engine optimization for dummies","seo referencement","consultant en referencement naturel","devis referencement","top seo company","expert référencement naturel"]
```

Ensuite, on va transformer cet ensemble en un sac de mots (un corpus de mots en quelque sorte), en découpant sur l'espace, puis en mettant tout "à plat" et en dédoublonnant.

``` ruby
words = keywords.map do |k|
  k.split(' ')
end.flatten.uniq
```

Enfin, on va créer nos vecteurs en bouclant sur chaque mot-clé et en respectant une logique binaire : si le mot-clé contient le mot du corpus, on attribue 1, sinon on attribue 0.
Ce qui donne :

``` ruby
vectors = keywords.map do |p|
  words.map do |w|
    p.include?(w) ? 1 : 0
  end
end
```

### 3. Partitionnez !

Le plus dur est fait ! Il faut désormais choisir un nombre k de centroids : ici on va prendre par exemple 5. En sortie, nous aurons donc *5 clusters*.

``` ruby
k = 5
```

Puis on instancie la classe `KMeansClusterer`, en lui passant en paramètre le nombre de centroids, les vecteurs, les labels (mots-clés) et le nombre d'itérations maximum. La méthode `run` permet de lancer le traitement des données.

``` ruby
kmeans = KMeansClusterer.run k, vectors, labels: keywords, runs: 5
```

Il ne reste plus qu'à afficher les données en console.

``` ruby
kmeans.clusters.each do |cluster|
  puts  cluster.id.to_s + '. ' +
        cluster.points.map(&:label).join(", ") + "\r\t"
end
```

Voici les résultats :

``` console
0. référencement seo, agence seo, agence référencement, expert référencement, seo referencement, referenceur freelance, référenceur freelance

1. consultant en référencement naturel, consultant référencement naturel, consultant en référencement, consultant référencement, référencement naturel, consultant référencement internet, spécialiste référencement naturel, expert référencement naturel

2. consultant en referencement, consultant referencement, consultant referencement naturel, consultant en referencement naturel, referencement naturel, expert referencement, experts referencement

3. agence de referencement, agence referencement, agence de référencement, devis referencement

4. consultant seo, expert seo, conseil seo
```

## Analyse des résultats et amélioration

Comme on peut le voir, les résultats pourraient être meilleurs si, au préalable, on avait normalisé les données : suppression des stop words, suppression des accents. En faisant cela, on éviterait par exemple que "consultant en référencement naturel" soit dans un cluster différent de "consultant en referencement naturel".
Pour autant les résultats sont plutôt cohérents.

Voilà pour cette première tentative de clustering. Certes, la méthode n'est pas aussi efficace que je l'aurais souhaité et présente l'inconvénient de devoir connaître le nombre de clusters *a priori*, mais le gros avantage est qu'elle est peu coûteuse en termes d'implémentation et de performance ;)

Et vous, utilisez-vous cette méthode ?
