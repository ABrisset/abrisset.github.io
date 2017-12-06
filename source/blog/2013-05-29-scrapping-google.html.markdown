---
title: "Scraper Google avec deux plug-ins Chrome"
title_seo: "Scraper Google : deux extensions Google Chrome"
description: "Une petite technique agile pour scraper les résultats Google sans quitter son navigateur. Deux plug-ins Chrome suffisent !"
date: 2013-05-29
hero_image: tool.jpg
thumbnail:
category: "Outils SEO"
excerpt: "Quand on n'a pas Scrapebox ou RDDZ sous la main pour scraper les résultats de Google, il est intéressant de disposer d'outils qui pourront faire le travail malgré tout. Je vais donc vous présenter une petite méthode 'artisanale' pour récupérer les résultats de Google en quelques clics."
author:
slug: /scrapping-google
---

## Charger les pages de résultats

Tout d'abord, commencez par installer sur votre navigateur Google Chrome l'extension Autopager disponible [ici](https://chrome.google.com/webstore/detail/autopager-chrome/mmgagnmbebdebebbcleklifnobamjonh?hl=fr), que j'avais découverte via [un article de 512Banque](http://www.deliciouscadaver.com/aspirer-les-resultats-google-manuellement-mais-rapidement.html). Cette extension permet, dans le cadre d'une pagination, de charger la page suivante dès que vous arrivez à la fin de la précédente. Une sorte d'infinite scroll à activer sur demande qui vous fera économiser de nombreux clics.

Une fois l'extension activée, rendez-vous sur Google et testez la en formulant une requête. Vous devriez voir apparaître ceci en bas de page :

![Autopager](/images/posts/autopager.jpg "Autopager")

Vous pouvez ensuite si vous le voulez définir le nombre de pages à précharger en cliquant sur "load" et en indiquant le nombre de pages voulues.

## Extraire les résultats avec Xpath Helper

Une fois que vous avez chargé toutes vos pages, l'objectif va être de rechercher dans le DOM les éléments qui nous intéressent, à savoir les liens de résultats Google. Pour cela, nous allons utiliser l'extension [Xpath Helper](https://chrome.google.com/webstore/detail/xpath-helper/hgimnogjllphhhkhlmebbmlgjoejdpjl). Celle-ci permet d'extraire le contenu du DOM en exécutant les requêtes Xpath de notre choix. Pour la télécharger, ça se passe [ici](https://chrome.google.com/webstore/detail/xpath-helper/hgimnogjllphhhkhlmebbmlgjoejdpjl). Il vous suffit de faire la combinaison de touches CTL + MAJ + X pour lancer l'extension qui s'affiche sous forme d'overlay en haut de votre navigateur.

Il ne reste plus qu'à lancer une requête Google, identifier le chemin Xpath des résultats de recherche et extraire le contenu. La chaîne Xpath est la suivante :

``` code
    //h3[@class="r"]/a/@href
```

Vous devriez donc obtenir ce genre de résultats :

![Xpath Helper](/images/posts/xpathhelper-1024x239.jpg "Xpath Helper")

Copiez les URLs de la partie "Results" et collez les dans votre éditeur de texte favori. 99% des URLs retrouvées devrait être au bon format, cependant il se peut que vous trouviez dans votre échantillon quelques URLs sous la forme url?sa=...

Avec la regex ci-dessous, vous pourrez isoler l'URL recherchée :

Rechercher

``` code
    ^\/.*url=(.*)&ei=.*$
```

Remplacer

``` code
    $1
```

Il ne restera plus qu'à décoder les URLs concernées. Certains éditeurs de texte tels que Sublime Text proposent des plugins d'url encode/decode qui font très bien l'affaire ;)

Bien entendu, cette méthode ne gère pas la question des proxies. Elle est donc à considérer comme une alternative légère à des solutions plus puissantes pour scraper en masse...
