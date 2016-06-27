---
title: "Méfiez-vous des plugins wordpress seo-friendly"
title_seo: "Plugins Wordpress seo-friendly : méfiez-vous !"
description: "Avant d'installer un plugin wordpress, prenez le temps de vérifier la façon dont il est codé pour éviter certains écueils. Démonstration ici avec Recipress."
date: 2014-01-07
hero_image: on-site.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Wordpress est un CMS très pratique quand il s'agit de monter un petit projet sans devoir trop mettre les mains dans le cambouis. Le gros avantage est en effet de pouvoir utiliser la myriade de plugins disponibles pour greffer différentes fonctionnalités au site, sans même quitter la console d'admin. Pour autant, il convient de rester vigilant lors de l'utilisation d'un plugin. Retour d'expérience."
author:
---

## Un plugin SEO-friendly... a priori

Pour un petit projet personnel, j'ai utilisé le [plugin "Recipress"](http://wordpress.org/plugins/recipress/), permettant de mettre en forme des recettes de cuisine pour Wordpress.

Les avantages pour le SEO :

* possibilité de créer une navigation secondaire via des taxonomies (ingrédients, types de plats, niveau de difficulté)

* intégration des microformats hRecipe avec tous les champs qui vont bien : photo de la reette, nom de la recette, temps de prépration, temps de cuisson, etc.

* et même une suggestion d'ingrédients afin de conserver la même orthographe et ainsi ne pas générer de pages tags (basées sur ces ingrédients) en doublon

## Petit tour dans le code source

En regardant de plus près le code source, je me suis rendu compte que le plugin allait un peu loin dans l'optimisation, un peu trop loin même. En effet, une fonction du plugin se charge d'afficher un résumé de la recette lorsque celui-ci n'a pas été entrée à la mano en se basant sur les 140 premiers caractères de l'article :

``` php
// summary
		$summary = recipress_recipe('summary');
		if(!$summary)
			$recipe['summary'] = '<p class="summary seo_only">'.recipress_gen_summary().'</p>';
		else
			$recipe['summary'] = '<p class="summary">'.$summary.'</p>';
```

Sur ce contenu, le plugin applique une class CSS "seo_only" et là surprise :

``` css
#recipress_recipe .seo_only {
	display:none;
}
```

Le contenu est **masqué** aux utilisateurs mais bien présent pour les moteurs !
Cette classe seo_only se retrouve d'ailleurs une seconde fois dans le code, pour masquer les informations sur l'author...
Bref, une technique peu recommandable qui envoie directement un warning à Google.

## En conclusion

Avant d'utiliser un plugin wordpress, et de surcroît lorsque celui-ci se targue d'être optimisé pour le SEO, pensez toujours à aller jeter un oeil au code source.
Parfois les éditeurs de plugin veulent bien faire, et c'est surement le cas pour l'éditeur de Recipress, qui du reste, est un plugin très pratique. Néanmoins, ces add-ons peuvent à votre insu plomber votre référencement, alors soyez vigilants !
