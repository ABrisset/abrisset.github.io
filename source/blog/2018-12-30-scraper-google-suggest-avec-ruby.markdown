---
title: Scraper Google Suggest avec Ruby
title_seo: "Scraper les Suggestions de Mots-clés Google (Google Suggest) avec Ruby"
description: "Je vous explique comment récupérer automatiquement toutes les suggestions Google autour d'un mot-clé. Avec en bonus un script gratuit !"
date: 2018-12-30 15:52:15 +0100
hero_image:
thumbnail:
category: "Scripts SEO"
excerpt: Google Suggest, tous les référenceurs connaissent. C'est souvent un des points de départ d'un audit de mots-clés. Plusieurs outils (payants) existent aujourd'hui pour récupérer ces mots-clés. Je vous propose ici un script Ruby gratuit.
author:
slug: /google-suggest-scraper
---

Ce petit outil va vous faciliter la tâche lors de l'extraction des mots-clés Google Suggest. Lancez-le, attendez quelques secondes et récupérez automatiquement toutes les suggestions dans un fichier .txt !

## Quelle différence par rapport aux outils et scripts existants ?

La plupart des scripts que j'ai pu trouver sur le net se "contentent" de récupérer les 10 premiers mots-clés proposés par Google Suggest lors d'une recherche. C'est bien, mais clairement insuffisant pour faire le tour d'une thématique. L'objectif est de collecter TOUS les mots-clés que nous offre Google.

Quand aux outils payants, ils font souvent bien le job, en ajoutant notamment les volumes de recherche correspondants, mais ils ont pour principal inconvénient... d'être payant :)

## Le script Ruby

Le script que je vous propose utilise l'API Google disponible ici https://www.google.com/complete/search?output=toolbar&hl=fr&q=mot-cl%C3%A9. Pour chaque requête, celle-ci renvoie en sortie un fichier XML contenant 10 résultats maximum.

L'objectif est donc :
- d'interroger l'API
- de parser le XML
- de collecter les suggestions de mots-clés
- de tester si chaque nouvelle suggestion déclenche à son tour de nouvelles suggestions

Par exemple, sur le requête "iphone", si l'API renvoie en premier résultat "iphone xr", il faut tester si "iphone xr" renvoie lui aussi des résultats. Si c'est le cas, il va falloir à nouveau tester chaque nouvelle suggestion que l'API nous renvoie. Et ainsi de suite...

L'aspect intéressant dans le développement de l'outil a donc été l'utilisation de la récursivité, c'est-à-dire l'appel d'une méthode dans la méthode elle-même.

## Comment utiliser le script ?

Le script est disponible sur [Github](https://github.com/ABrisset/google_suggest_scraper). 
Pour l'utiliser, il suffit de cloner le repo sur votre machine puis de lancer la commande suivante :

``` ruby
ruby scraper.rb -q "votre mot-clé"
```

Si je trouve le temps, j'en ferai une app et ajouterai peut-être même une visualisation.

Amusez-vous bien !