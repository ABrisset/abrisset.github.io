---
title: "Recherches associées Google : décryptage et méthode de scrape"
title_seo: "Recherches associées Google : décryptage + scraper"
description: "Quelques pistes de réflexion sur la façon dont Google sélectionne les mots-clés du bloc recherches associées et en bonus un cript CasperJS pour les scraper !"
date: 2014-05-30
hero_image: semantic.jpg
thumbnail:
category: "Sémantique"
excerpt: "Depuis quelques temps, le blog de <a href='http://www.seobythesea.com/'>Bill Slawski</a> est entré dans mes favoris. En décryptant les différents brevets publiés par Google, cet auteur très réputé aux Etats Unis permet aux référenceurs de mieux comprendre comment fonctionne Google et surtout de découvrir quelles méthodes de traitement automatiquement du langage sont à l'oeuvre du côté de Mountain View. Ses billets sur les recherches associées ou <strong>related queries</strong> ont particulièrement attiré mon attention. Ce sera donc l'objet de cet article, avec, en bonus, un petit script maison pour scraper les recherches associées avec CasperJS (voir <a href='http://www.deliciouscadaver.com/casperjs-ou-comment-construire-un-submitter-open-source.html'>l'article de 512Banque</a> pour une présentation sous l'angle SEO)."
author:
---

## Comment Google détermine-t-il les "entités" à associer à une recherche ?

Ce sujet ayant été peu abordé dans la blogosphère SEO française, je vous propose de vous donner quelques éléments de réflexion que j'ai pu trouver, en lisant notamment le blog Seobythesea.

Lorsque vous soumettez une requête sur Google, le moteur de recherche va effectuer plusieurs traitements pour déterminer des termes "candidats" qui pourront être associés à votre requête et affichés en tant que "recherches associées", vous permettant ainsi d'affiner votre recherche initiale.

Ces termes candidats sont appelés des "entités" dans les différents brevets de Google. Ce concept d'entité fait grand bruit aux Etats-Unis et au Royaume-Uni en ce moment, un peu moins en France. Pour ceux qui ne seraient pas familiers avec ce terme, l'entité va au-delà de la simple chaîne de caractères, car elle se conçoit en relation avec d'autres entités, **dans un contexte**. Concrètement, les entités peuvent être des Personnes (People), des Lieux (Place) ou des Choses (Thing).

Si l'on se réfère en particulier aux travaux d'Ori Allon, brevetés par Google, et que l'on considère que les méthodes décrites dans ses travaux sont encore d'actualité chez Google, le moteur de recherche américain serait aujourd'hui en mesure d'utiliser 3 sources de données pour trouver des termes candidats au *"refinement"* de la requête initiale, comme expliqué [dans cet article](http://www.seobythesea.com/2013/03/google-query-refinements-orion/) de Bill Slawski que je vais essayer de retranscrire ci-dessous.

### 1. Les documents retournés dans les résultats de recherche pour la requête initiale

Pour déterminer les entités associées à chacun de ces documents, Google pourrait vérifier quelles sont les mots-clés les plus significatifs de chaque document en appliquant tout d'abord un score [IDF](http://fr.wikipedia.org/wiki/TF-IDF#Fr.C3.A9quence_inverse_de_document) (Inverse Document Frequency) à chacune des entités trouvées dans le document. Si une entité apparait de nombreuses fois dans les documents indexés sur cette requête, ce n'est pas forcément un bon candidat, car pas suffisamment discriminant pour ce document. D'où l'idée de calculer cet IDF.

Cet IDF pourrait être combiné à un score de co-occurences, c'est-à-dire au nombre de fois où cette entité apparait dans le document : la probabilité que cette entité soit importante pour le document étant plus forte si elle apparait de nombreuses fois au sein de ce document.

Si l'entité apparait dans le title, le score de cet entité pourrait également augmenter.

### 2. Le comportement de recherche des internautes

Google pourrait également s'intéresser au nombre de fois où l'entité candidate est apparue dans les recherches précédentes (logs), sur une période donnée.

De même, si pour plusieurs requêtes successives qui contiennent l'entité candidate, un même document est retourné comme résultat, Google pourrait prendre en compte le temps de consultation de ce document, qualifié de "dwell time". S'il est jugé suffisant, le document est considéré comme pertinent par rapport à l'entité. Plus ce temps passé sur la page est long, plus le score de l'entité augmente.

### 3. La fraicheur des résultats

Pour garantir des recherches associées en corrélation avec l'actualité, Google pourrait également prendre en considération certaines sources d'informations "chaudes" comme des articles de presse, des articles de blog, des sites de microblogging (hello Twitter) et vérifier si certaines entités retrouvées dans ces sources sont pertinentes par rapport à la requête initiale.


Une fois les entités collectées pour chaque document, via les 3 sources de données que je viens de présenter, le processus de sélection des entités à retenir pourrait s'appuyer sur :

- la longueur de l'entité (nombre de tokens)
- le nombre de fois où ces entités apparaissent dans les résultats de recherche pour la requête initiale
- le degré de correspondance entre la requête initiale et l'entité
- le nombre de fois où l'entité est apparue dans les logs de recherche, et avec quelle intensité
- la somme des IDF des tokens composant l'entité
- etc.


J'espère avoir su restituer de façon assez claire les explications de Bill Slawski et avoir pu mettre en lumière quelques uns des mécanismes qui se cachent derrière ces fameuses recherches associées, et que vous trouverez une utilité à les intégrer dans votre travail de référencement.

Faîtes une recherche sur Google, ouvrez quelques pages de résultats, identifiez des mots-clés significatifs puis jetez ensuite un coup d'oeil aux recherches associées. Vous devriez faire quelques rapprochements ;)

Je vous donne maintenant un petit coup de pouce avec ce script CasperJS qui va vous permettre de les scraper très facilement, depuis votre console.

## Scrapez les recherches associées avec CasperJS

Avec CasperJS, on peut faire un peu tout et n'importe quoi : scraper des élements HTML, soumettre des formulaires, prendre des screenshots, suivre des liens, etc.

J'ai donc utilisé cet utilitaire javascript pour scraper les mots-clés des recherches associées Google.

Après avoir passé un mot-clé en argument, Casper se connecte sur Google.fr, effectue une recherche sur ce mot-clé, scrape le texte contenu dans les balises "a" du bloc de recherches associées et les affiche les unes à la suite des autres, en console.

J'ai ajouté le code [sur Github](https://github.com/ABrisset/casperjs-related). Bon scraping !
