---
title: Analyser les données Search Console avec Google Sheets & Blockspring
title_seo: "Requêtes Google Webmaster Tools : analyse avec Google Docs & Blockspring"
description: "Découvrez comment utiliser Google Sheets et l'add-on Blockspring pour analyser les données de Google Search Console et mieux optimiser votre site !"
date: 2016-03-29 20:12:04 +0200
hero_image: tool.jpg
thumbnail:
category: "Outils SEO"
excerpt: "Google Sheets est un excellent outil que j'utilise beaucoup dans mon activité SEO : pour générer des reporting avec l'API analytics, pour trier des mots-clés, ou même pour extraire les résultats Google sur une requête (même s'il semblerait que cela ne fonctionne plus depuis quelques semaines). Couplé à l'add-on Blockspring, les possibilités sont multiples."
author:
---

[Blockspring](https://www.blockspring.com/) est un outil magique qui permet de se connecter facilement à tout un tas d'API et que l'on peut plugger à Excel ou à Google Sheets en quelques clics. Dans cet article, je vous présente une métholodogie simple d'utilisation de Google Sheets et de Blockspring pour analyser les données de Search Console issues du rapport *Analyse de la recherche*.

## Installer l'add-on Blockspring

Avant toute chose, [créez un compte sur Blockspring](https://open.blockspring.com/users/sign_up).
Ensuite, direction Google Sheets : créez un nouveau tableur et installez l'add-on Blockspring, disponible [ici](https://chrome.google.com/webstore/detail/blockspring/aihldeahgcpbpmimkdpkafaedhbmfhoh).
Ouvrez le panel Blockspring en cliquant sur *Modules complémentaires* > *Blockspring* > *Open*.
Une petit fenêtre s'ouvre sur la gauche, connectez-vous avec les infos utilisées lors de la création du compte, vous voilà prêt à démarrer.

![Login Blockspring](/images/posts/blockspring-login.png "Login Blockspring")

<u>NB</u> : pour que Blockspring fonctionne correctement, vous devez modifier les paramètres de votre feuille de calcul. Dans *Fichier*, cliquez sur *Paramètres de la feuille de calcul* puis sélectionnez "États-Unis" dans les paramètres régionaux et enregistrez.

## Ajouter le block Google Webmaster Tools

Une fois connecté, recherchez "Google Webmaster Tools" parmi la liste des API disponibles. Une fois que vous l'avez sélectionnée, cliquez sur *Analytics Query*, choisissez le site et les dates de début/fin souhaitées, et cliquez sur *Select Optional Parameters*. Cochez *Dimensions* et *Search Type*. Deux nouveaux champs apparaissent. Dans Dimensions, sélectionnez *Page* et *Query* puis dans Search Type, sélectionnez *Web* (ou *Image* si vous voulez procéder à une analyse de votre ranking Google Images).
Attendez quelques secondes, les données apparaissent !

* colonne A : l'URL de la landing page
* colonne B : la requête
* colonne C : le nombre d'impressions
* colonne D : le nombre de clics
* colonne E : le taux de clics (CTR)
* colonne F : la position

## Analyser les données
### Dans quel objectif ?

L'objectif de l'analyse va être de repérer les mots-clés pour lesquels le site enregistre de nombreuses impressions mais un positionnement au-delà de la 3ème position et/ou un taux de clics faible, puis d'en déduire des pistes d'optimisation SEO en couplant ces données à d'autres données on-page.

### Filter les positions

Commençons par trier les mots-clés par ordre décroissant d'impressions : a priori, ce sont des mots-clés dont le potentiel de recherche est le plus important. Arrondissons les positions à l'entier le plus proche, puis filtrons celles-ci en ne retenant que celles inférieures ou égales à 20. Au-delà, l'effort à accomplir pour améliorer le positionnement risquerait de ne pas être "rentable".

Je me suis ensuite inspiré du très bon [article de Mickaël Challet](http://www.mickael-challet.com/developper-son-traf-seo/) pour appliquer une mise en forme conditionnelle en colonne G : si le taux de clics est inférieur à la valeur attendue pour la position moyenne (selon les dernières études sur les taux de clics), j'affiche "KO" en rouge. Sinon, j'affiche "OK" en vert.

```
=IF(AND(F2=1,E2<0.2),"KO",IF(AND(F2=2,E2<0.11),"KO",IF(AND(F2=3,E2<0.08),"KO",IF(AND(F2=4,E2<0.05),"KO",IF(AND(5<F2<11,E2<0.0327),"KO",IF(AND(F2>10,E2<0.014),"KO","OK"))))))
```

Vous voilà donc avec un tableur dont les mots-clés sont classés par ordre de priorité.

![Données Search Console](/images/posts/data-search-console.png "Données Search Console")

### Ajouter des informations on-page pour chaque URL

Pour compléter l'analyse, ajoutons une colonne H avec, pour chaque URL, sa balise title. Utilisons la fonction IMPORTXML pour faire cela :

```
=IMPORTXML(A2,"//title[1]")
```

Ajoutons également en colonne I la balise meta description :

```
=IMPORTXML(A2,"//meta[@name='description']/@content")
```

Profitons enfin de Blockspring pour extraire le contenu textuel de chaque page. Pour faire cela, il est possible par exemple de passer par [AlchemyAPI](http://www.alchemyapi.com/), disponible via Blockspring, et d'utiliser sa fonction d'extraction de texte à partir d'une URL. Bien entendu, vous devrez auparavant vous inscrire sur AlchemyAPI pour récupérer un jeton qui vous permettra d'utiliser l'API. Si tout se passe bien, en colonne J, vous pourrez utiliser la fonction suivante :

```
=BLOCKSPRING("extract-text-from-url-with-alchemyapi","url",A2)
```

Maintenant que vous avez le contenu, vous allez pouvoir compter le nombre de mots en colonne K, afin de déterminer si votre contenu est suffisamment long pour prétendre à un bon positionnement sur le mot-clé. Dans une nouvelle colonne, ajoutez la fonction suivante (si vous êtes curieux de comprendre comment fonctionne cette fonction, rendez-vous [ici](https://exceljet.net/formula/count-total-words-in-a-cell)) :

```
=LEN(TRIM(J2))-LEN(SUBSTITUTE(J2," ",""))+1
```

Vous disposez désormais de quatre informations de base par rapport à votre couple mot-clé / URL :

* le title de la page
* la meta description de la page
* le contenu de la page
* le nombre de mots dans la page

![Tableur final](/images/posts/data-google-sheets.png "Tableur final")

Il ne vous reste plus qu'à analyser les mots-clés pour lesquels votre taux de clics n'est pas satisfaisant, ou pour lesquels votre positionnement pourrait être meilleur et à réfléchir à des optimisations possibles, telles que :

* ajouter le mot-clé dans la balise title
* mettre le mot-clé davantage en début de balise title
* reformuler la meta description pour inciter davantage au clic
* étoffer le contenu
* etc.

Je vous invite également à jeter un oeil à toutes les API disponibles dans Blockspring, il est possible d'aller bien plus loin encore dans l'analyse des URL, sans sortir de votre feuille de calcul.
En vrac :

* classifier un texte à partir d'une URL (disponible [via Aylien](https://open.blockspring.com/bs/classify-text-with-aylien) pour les corpus français)
* compter le [nombre d'occurences](https://open.blockspring.com/pkpp1233/count-occurrence-of-string-within-text) d'un mot dans un texte
* récupérer le nombre de partages ou de likes d'une URL avec [SharedCount](https://open.blockspring.com/pkpp1233/share-counts-url-sharedcount)
* etc.

A vous de jouer !
