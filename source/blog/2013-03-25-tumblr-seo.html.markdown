---
title: "Optimisation de Tumblr pour le référencement"
title_seo: "Tumblr SEO : tutoriel d'optimisation"
description: "Un tutoriel sur l'optimisation de Tumblr pour le SEO : title, meta description, gestion de la pagination, tous les conseils pour bien référencer votre blog Tumblr !"
date: 2013-03-25
hero_image: on-site.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Tumblr est une plateforme qui a le vent en poupe depuis maintenant quelques années. Fortement socialisée, elle bénéficie d'un réel pouvoir communautaire et peut également, comme toute plateforme de blogging gratuite, être utilisée dans une stratégie globale de référencement naturel. Néanmoins, par défaut, la plupart des thèmes présentent des lacunes en termes d'optimisation on-site. Voici donc quelques conseils pour en faire une plateforme performante pour le SEO."
author:
slug: /tumblr-seo
---

## 1. Optimiser les métadonnées

L'objectif est de pouvoir définir des balises title et meta différentes par types de page. Pour cela nous allons utiliser les "blocks" ainsi que les variables Tumblr, qui permettent d'afficher un rendu HTML spécifique en fonction d'un format de post, d'un set de données ou d'un type de page.

Ainsi, pour la gestion des balises title, voici comment vous pourriez procéder.

``` code
<title>
  {block:IndexPage}
    Mon titre optimisé | {Title}
  {/block:IndexPage}
  {block:PermalinkPage}
    {block:PostTitle}
      {PostTitle} | {Title}
    {block:PostTitle}
  {/block:PermalinkPage}
</title>
```

Les "blocks" agissent un peu à la manière des opérateurs if et else. Il s'ouvrent comme ceci {block:nom_du_block} et se ferment comme cela {/block:nom_du_block}. Les variables elles sont utilisées pour afficher des valeurs dynamiques en fonction de ces blocks :

* {Block:IndexPage} : rendu custom pour la page index
* {Block:PermalinkPage} : rendu custom pour un article
* {Block:PostTitle} : title à afficher pour un billet
* {Title} : le nom de votre site tel que vous l'avez défini en créant votre blog

De la même manière, nous pouvons donc optimiser les balises meta description.

``` code
<meta name="description" content="
  {block:IndexPage}meta description personnalisée pour la page d'accueil{/block:IndexPage}
  {block:PermalinkPage}{MetaDescription}{/block:PermalinkPage}"
/>
```

{MetaDescription} reprendra en meta description le titre de l'article ainsi que le début de l'article.

Vous pouvez également, si vous en êtes friand, ajouter la balise canonique sur vos pages articles.

``` code
{block:PermalinkPage}
  <link rel="canonical" href="{Permalink}" />
{/block:PermalinkPage}
```

Enfin, pour un partage optimisé sur Facebook, n'oubliez pas les balises de l'Open Graph Facebook.

``` code
<meta property="og:type" content="blog" />
<meta property="og:site_name" content="{Title}" />
<meta property="og:title" content="
  {block:IndexPage}Ma description personnalisée pour Facebook{/block:IndexPage}
  {block:PostSummary}{PostSummary}{/block:PostSummary}"
/>
<meta property="og:url" content="
  {block:IndexPage}L’URL de mon Tumblr{/block:IndexPage}
  {block:PermalinkPage}{Permalink}{/block:PermalinkPage}"
/>
```

A noter que {block:PostSummary} est identique à {block:PostTile}, la nuance étant qu'il permet de générer un title automatiquement si aucun titre n'a été rempli pour le billet.

Voilà pour ce qui est de la partie métadonnées. Passons maintenant au corps de vos pages.

## 2. Intégrer correctement les balises sémantiques

De la même manière que vous avez défini des règles de gestion pour vos balises title et meta, vous pouvez remplir différemment le contenu de vos balises hn en fonction du type de page appelé. Par exemple, le \<h1\> en page d’accueil sera placé sur le nom du site, alors qu'il sera placé sur le nom de l'article dans les pages articles.

Exemple de gestion du loop sur les derniers articles en page d'accueil.

``` code
<div class="content">
  {block:IndexPage}
    {block:Title}<h2><a href="{Permalink}">{Title}</a></h2>{/block:Title}
  {/block:IndexPage}
  {block:PermalinkPage}
    {block:Title}<h1>{Title}</h1>{/block:Title}
  {/block:PermalinkPage}
</div>
```

N'oubliez pas de changer vos styles CSS en conséquence ;)

## 3. Bien gérer les liens internes

Par défaut les thèmes tumblr génèrent beaucoup de liens en double ce qui n'est pas forcément optimal pour votre linking interne. Voici donc quelques pistes pour corriger cela.

En règle générale, Tumblr propose plusieurs liens pour accéder à un article depuis la home :

* un lien sur le titre de l'article
* un lien sur {continuer la lecture|lire la suite|read more|continue reading}
* un lien "permalien"
* un lien sur la date à laquelle a été publié l'article

Soyez cohérent et essayez de ne garder qu'au maximum deux de ces liens : celui sur le nom de l'article est celui qui transmettra le plus de "sémantique" à votre article. Il serait donc judicieux de conserver celui-ci, ainsi que le "read more" par exemple, pour des questions pratiques de navigation.

Par ailleurs, Tumblr génère des liens en double vers votre page d'accueil : lien sur le logo, lien sur l'avatar, parfois lien sur un bouton "accueil". Vous pouvez ici aussi effectuer quelques optimisations. Par exemple, sur la photo de profil, vous pouvez optimiser l'attribut alt et ajouter une ancre à la fin de votre lien (je n'ai pas re-testé récemment cette astuce qui fonctionnait il y a encore quelques mois, cf [http://blog.axe-net.fr/ancres-multiples-referencement-test-seo/](http://blog.axe-net.fr/ancres-multiples-referencement-test-seo/)).

Voici ce que cela donnerait.

``` code
<div id="ProfilePhoto">
  <a href="/#ancre">
    <img src="http://static.tumblr.com/dossier/image.png" width="" alt="Mes mots-clés"/>
  </a>
</div>
```

Enfin, si votre thème ne dispose pas par défaut d'une pagination, voici comment en ajouter une.

``` code
{block:Pagination}
  {block:PreviousPage}
    <a href="{PreviousPage}"> < </a>
  {/block:PreviousPage}
  {block:NextPage}
    <a href="{NextPage}"> > </a>
  {/block:NextPage}
{/block:Pagination}
```

Je ne m'étends pas plus, les tags sont ici très explicites.

## 4. Effectuer les derniers réglages SEO via le tableau de bord

Pour compléter ces optimisations basiques, il vous reste encore quelques configurations à effectuer via le tableau de bord. Tout d'abord assurez-vous que vous avez défini une description/un slogan pour votre site. D'une part elle vous permettra d'ajouter du contenu si elle est appelée à quelque endroit dans votre template (via la variable {Description}). D'autre part, c'est elle qui sera reprise en meta description si vous n'avez pas particulièrement optimisé celle-ci (voir le point 1.)

Par ailleurs, n'oubliez pas d'autoriser la customization des URLs. Bien utilisée cette fonctionnalité peut vous apporter un petit plus.

![RSS](/images/posts/rss.jpg "RSS")

Enfin, pour éviter l'effet de duplicate content, pensez à tronquer votre flux RSS en n'y affichant qu'un extrait de vos articles.

## Autres pistes d'optimisation

Bien entendu, l'optimisation ne s'arrête pas là et il vous reste de multiples éléments à configurer pour vous assurer que blog sera correctement indexé et visible dans les SERPs :

* ajouter des boutons sociaux
* minifier et externaliser les CSS via http://www.tumblr.com/themes/upload_static_file
* traduire le thème si besoin est
* ne pas ajouter trop de tags inutiles
* afficher seulement un extrait de vos articles en page d'accueil et non l'article entier
* etc.

Vous souhaitez installer un thème SEO friendly avec les 3/4 de ces optimisations déjà implémentées ? Jetez un coup d'oeil à [TumblrBareBone](https://github.com/SamMarkiewicz/TumblrBareBone)**, **un joli thème Tumblr qu'a conçu mon ami [Sam](http://sammarkiewi.cz/), en suivant mes recos SEO :)
