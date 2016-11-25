---
title: Installer un certificat SSL sur un site hébergé par Github Pages
title_seo: "Github Pages : SSL pour un custom domain"
description: "Vous utilisez Github Pages avec votre propre nom de domaine et vous souhaitez passer en https ? La solution gratuite est ici !"
date: 2016-11-04 19:41:24 +0100
hero_image: server.jpg
thumbnail:
category: "Administration Serveur"
excerpt: "Google pousse les webmasters du monde entier à utiliser https par défaut pour leur site web. Si vous avez un ou plusieurs sites hébergés sur Github Pages avec votre propre nom de domaine, vous recherchez sûrement un moyen d'installer un certificat SSL. Je vous propose ici une méthode rapide et gratuite."
author:
---

Github Pages, malheureusement, ne propose pas par défaut de forcer le chiffrement https si vous avez configuré un nom de domaine personnalisé.

![Enforce ssl - Github Pages](/images/posts/enforce.png "Enforce ssl - Github Pages")

Cependant, il existe une méthode gratuite et facile à mettre en place, que je vous explique en détails ici.

## Créez-vous un compte sur Cloudflare

La première étape consiste à vous créer un compte sur Cloudflare (ou à vous connecter si vous en possédez déjà un).
Déclarez votre site, et notez bien l'adresse des enregistrements DNS que vous fournit Cloudflare.

![DNS Cloudflare](/images/posts/dns-cloudflare.png "DNS Cloudflare")

## Modifiez vos DNS

Connectez-vous sur l'interface de votre registrar, et rendez-vous dans la section dédiée à la configuration des DNS. Ajoutez les serveurs DNS tels que définis par Cloudflare et supprimez les autres. Ci-dessous, un exemple avec OVH.

![DNS OVH](/images/posts/dns-ovh.png "DNS OVH")

## Paramétrez votre domaine dans Cloudflare

Rendez-vous ensuite sur Cloudflare, dans la section *Crypto*. Sélectionnez *Full* puis cliquez sur *Active certificate* pour générer et activer votre certificat. L'opération peut prendre plusieurs minutes.

![SSL](/images/posts/ssl-on.png "SSL")

## Mettez en place les règles de direction

Là où Cloudflare devient vraiment intéressant, c'est que, comme il intercepte toutes les requêtes vers votre domaine, il est possible de créer des règles de redirection d'URL en fonction de pattern spécifiques, sous forme d'expression régulière.
Ici, l'objectif va donc être de rediriger, en 301, toutes les requêtes vers des URL en http vers leur correspondance en https. Rendez-vous dans la section *Page rules* et mettez en place les directives suivantes (remplacez bien évidemment par votre domaine).

![Page rule Cloudflare](/images/posts/page-rule-1.png "Page rule Cloudflare")
![Page rule Cloudflare](/images/posts/page-rule-2.png "Page rule Cloudflare")

## Remplacez toutes vos URL http en https

Pour terminer, recherchez dans votre projet toutes les éventuelles URL en http et remplacez les par des URL en https (images, fonts, CSS, JS, etc.) pour ne pas avoir de problèmes de "mixed content".
Et voilà, vous avez maintenant un site seo-friendly qui délivre des pages en https !
