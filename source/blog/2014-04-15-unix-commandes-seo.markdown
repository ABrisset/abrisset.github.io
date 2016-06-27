---
title: "Unix : 5 commandes de base utiles pour le SEO"
title_seo: "Unix : 5 commandes de base utiles pour le SEO"
description: "Vous faites du SEO ? Vous avez un terminal sous la main ? Découvrez 5 commandes Unix/Linux pratiques pour vous assister au quotidien !"
date: 2014-04-15
hero_image: tool.jpg
thumbnail:
category: "Outils SEO"
excerpt: "Au quotidien, quand on travaille avec un système d'exploitation comme OS X ou Linux, il est pratique de pouvoir lancer certaines commandes dans le shell pour manipuler des fichiers, obtenir des informations sur des pages web, mesurer des temps de réponses, etc. Certaines commandes peuvent avoir un véritable intérêt pour le SEO. J'en donne ici 5 parmi mes favorites."
author:
---

## curl -I pour les en-têtes HTTP

Pour vérifier le contenu des en-têtes HTTP, et au lieu de passer par un plugin firefox/chrome aux résultats parfois hasardeux -- poke [@nicemedia_fr](https://twitter.com/nicemedia_fr), il est possible d'éxécuter la commande [curl -I](http://curl.haxx.se/docs/manpage.html#-I) suivie de l'URL que l'on souhaite inspecter. Cette commande va générer une requête HEAD sur le document demandé et retourner des informations aussi utiles que :

* le code réponse du serveur
* la taille du body, en octets
* les informations relatives à la mise en cache (Last-Modified, Expires, etc.)
* le type de serveur utilisé
* la présence éventuelle d'un Link rel canonical
* la présence éventuelle d'un [X-Robots-Tag](http://www.antoine-brisset.com/blog/noindex-nginx/)
* etc.

``` console
curl -I http://blog.antoine-brisset.com

HTTP/1.1 200 OK
x-amz-id-2: krgm1ZdR8dp54UipNmuSzaXbvL2R//UcK2xCMpySzteYf9XowI2u+M4xkJNNXPU/
x-amz-request-id: A8A88A89E04CAA52
Date: Tue, 15 Apr 2014 20:45:25 GMT
Last-Modified: Tue, 04 Feb 2014 12:43:39 GMT
ETag: "8b29264e6c647421e35f82b60a64c75a"
Content-Type: text/html
Content-Length: 18209
Server: AmazonS3

```

## wget pour les redirections

Vous devez tester rapidement une ou plusieurs redirections 301 mises en place sur votre site ? C'est wget qu'il faut utiliser. Par défaut, [wget](http://www.gnu.org/software/wget/manual/html_node/HTTP-Options.html) permet de suivre jusqu'à 20 redirections. Vous pouvez changer ce comportement par défaut avec l'option --max-redirect.

``` console
wget antoine-brisset.com --max-redirect=1 -O /dev/null

--2014-04-17 08:00:04--  http://antoine-brisset.com/
Resolving antoine-brisset.com... 213.186.33.19
Connecting to antoine-brisset.com|213.186.33.19|:80... connected.
HTTP request sent, awaiting response... 301 Moved Permanently
Location: http://www.antoine-brisset.com/ [following]
--2014-04-17 08:00:05--  http://www.antoine-brisset.com/
Resolving www.antoine-brisset.com... 213.186.33.19
Reusing existing connection to antoine-brisset.com:80.
HTTP request sent, awaiting response... 200 OK
Length: 5110 (5.0K) [text/html]
Saving to: ‘/dev/null’
```

A noter que le programme wget permet de lancer de nombreuses autres tâches comme le téléchargement récursif de fichiers par exemple.

## host pour les DNS lookup

Pour effectuer des reverse Dns, autrement dit pour convertir des adresses IP en nom de domaine, il suffit de lancer la commande [host](http://linux.about.com/library/cmd/blcmdl1_host.htm) suivi de l'IP à interroger. Utile pour vérifier Googlebot par exemple.

``` console
host 66.249.66.1

1.66.249.66.in-addr.arpa domain name pointer crawl-66-249-66-1.googlebot.com.
```

A noter qu'il existe aussi sa petite cousine "dig", qui elle donne des informations détaillées sur les enregistrements DNS.

## whois pour les noms de domaines

Pour avoir des infos sur les noms de domaine, par exemple si vous cherchez à récupérer un mail de contact dans votre démarche de partenariat *netlinking* (tiens, ça fait longtemps que je n'avais pas utilisé ce mot), lancez la commande [whois](http://linux.die.net/man/1/whois) suivi du domaine visé, et vous obtenez toutes les infos relatives à l'enregistrement du domaine : registrar, contact technique, date d'enregistrement du domaine, date d'expiration, etc.

``` console
whois antoine-brisset.com

Whois Server Version 2.0

Domain names in the .com and .net domains can now be registered
with many different competing registrars. Go to http://www.internic.net
for detailed information.

   Domain Name: ANTOINE-BRISSET.COM
   Registrar: OVH
   Whois Server: whois.ovh.com
   Referral URL: http://www.ovh.com
   Name Server: DNS17.OVH.NET
   Name Server: NS17.OVH.NET
   Status: clientDeleteProhibited
   Status: clientTransferProhibited
   Updated Date: 06-dec-2013
   Creation Date: 05-dec-2010
   Expiration Date: 05-dec-2014
```

## curl -w pour les temps de réponse

J'ai récemment découvert que l'on pouvait utiliser cURL pour afficher en sortie dans la console un certain nombre de données relatives aux temps de chargement des pages, à l'aide de [variables](http://curl.haxx.se/docs/manpage.html#-w) telles que :

- %{time_namelookup} : le temps de résolution DNS
- %{time_connect} : le temps de connexion au serveur
- %{time_starttransfer} : le TTFB (time to first byte), c'est à dire le temps qui s'écoule avant que ne soit reçu le premier octet de données par le client
- %{time_total} : le temps total de chargement, qui mesure le temps écoulé jusqu'au dernier octet transféré

Les temps de réponses sont donnés en millisecondes. En formatant la sortie dans le terminal (flag -w), on peut obtenir des choses assez sympas :

``` console
curl -w '\nRésolution DNS:\t%{time_namelookup}\nConnexion au serveur:\t%{time_connect}\nTTFB:\t%{time_starttransfer}\n\n-----------\nTotal time:\t%{time_total}\n' -o /dev/null -s http://blog.antoine-brisset.com/

Résolution DNS: 0,003
Connexion au serveur: 0,107
TTFB: 0,279

-----------
Total time: 0,286
```

En analysant les données de l'output, on peut avoir quelques idées d'optimisation. A noter que le -s signifie "silent", il permet de ne pas afficher de barre de progression ou de message d'erreur. Je signale au passage l'outil AB (Apache Benchmark) que j'ai découvert via [@jeanbenoit](https://twitter.com/jeanbenoit), et qui mesure tout un tas de choses relatives à votre serveur Apache.


Et voilà pour ce tour d'horizon des commandes Unix/Linux utiles pour le SEO. J'aurais pu citer également gunzip, diff et bien d'autres commandes mais cela fera peut être l'objet d'un prochain article :)
