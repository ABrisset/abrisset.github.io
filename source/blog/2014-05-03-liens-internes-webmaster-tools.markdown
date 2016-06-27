---
title: "Webmaster Tools : comment Google compte-t-il les liens internes ?"
title_seo: "Webmaster Tools : comment Google compte-t-il les liens internes ?"
description: "Comment Google compte-t-il les liens internes de votre site web ? Début de réponse grâce à ce test qui vous en dit plus sur l'onglet liens internes de Webmaster Tools."
date: 2014-05-03
hero_image: on-site.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Après avoir essayé de décrypter la façon dont Google comptait <a href='http://www.antoine-brisset.com/blog/mots-cles-webmaster-tools/'>les occurences de mots-clés</a>, j'ai cette fois-ci mené l'enquête sur l'onglet <strong>Trafic de recherche > Liens internes</strong> de Google Webmaster Tools, qui est, de mon point de vue en tout cas, peu utilisé / analysé par les SEO. L'objectif de ce test était de savoir si Google comptabilisait ou non les liens multiples pointant d'une page interne A vers une page interne B (cf <strong>First link counts rule</strong>)"
author:
---

## Crawl et collecte des liens

Pour réaliser ce test, j'ai à nouveau utilisé le site [Keewa.net](http://www.keewa.net), et ce pour deux raisons :

* il est inscrit dans Google Webmaster Tools (logique)
* aucune mise à jour n'a été faite sur le site depuis plusieurs mois : les données Webmaster Tools sont donc a priori fiables

Première étape, il fallait crawler le site et répertorier tous les liens internes sortants de chaque page. Pour faire cela, j'ai utilisé la gem [Anemone](http://anemone.rubyforge.org/). Pour chaque URL, j'ai donc collecté les liens internes grâce à la méthode "links". Il est à noter, comme expliqué [dans la doc](http://rdoc.info/github/chriskite/anemone/Anemone/Page:links), que cette méthode récupère uniquement les liens internes **distincts** contenus dans une page. Les liens internes doublons sur une même page ne sont donc comptés qu'une fois.

## Comptage des liens pour chaque URL

Anemone stocke les liens internes de chaque page dans un array. J'ai donc mergé chacun de ces array dans un array global. Puis, pour compter le nombre de liens reçus par chaque page en interne, voici comment je m'y suis pris :

``` ruby
def find_links(array_of_arrays)
  hash          = Hash.new(0)                     # on crée un nouveau hash
  total_links   = array_of_arrays.flatten         # on crée un seul array avec tous les liens
  total_links.each do |v|                         # on boucle sur chaque clé et on incrémente la valeur
    hash[v] += 1
  end
  hash_links.sort_by{ |key, value| value }.reverse # on trie par ordre décroissant du nombre d'occurences
end
```

Voici les données que j'obtiens dans mon hash :

``` ruby
{
 "http://www.keewa.net/"=>5,
 "http://www.keewa.net/film.php"=>5,
 "http://www.keewa.net/serie.php"=>5,
 "http://www.keewa.net/musique.php"=>5,
 "http://www.keewa.net/fonctionnement.php"=>5
}
```

Chaque page reçoit **5 liens** d'après mon crawler.

Chaque page reçoit **4 liens** d'après Google, cf capture ci-dessous.

![Liens internes](/images/posts/wmt_links_1.png "Liens internes")

Si on compare les deux jeux de données, on remarque donc qu'il y a une différence de seulement un lien interne pour chaque page entre les deux méthodes de comptage. D'où vient cette différence ?

En cliquant sur la page /musique.php dans Google Webmaster Tools, je peux accéder aux différentes pages qui font des liens vers la dite page /musique.php, je peux donc comparer cela à mon propre jeu de données. La différence, visiblement, c'est que mon crawler comptabilise **l'auto link**, c'est-à-dire le lien qu'une page se fait vers elle-même, alors que Google non. Dans mon cas, sur la page /musique.php on retrouve en effet un auto lien vers /musique.php dans le menu de navigation.

## Conclusions

A l'issue de ce test, je tire deux conclusions intéressantes :

* la première est que Google Webmaster Tools semble ne pas compter les liens multiples d'une page vers une page B. S'il y en a plusieurs, il dédoublonne et il n'en retient qu'un.
* la deuxième est que Google semble ne pas prendre en compte les auto links

Bien entendu, il faut prendre ces analyses avec des pincettes : d'une part, il faudrait reproduire ce test sur d'autres sites, pour vérifier si on obtient les mêmes résultats ; d'autre part, rien ne prouve que ce qui est communiqué par Google dans ses Outils pour les Webmasters est identique à ce qui est utilisé par l'algorithme de classement.

Je vous laisse donc vous faire votre propre opinion : selon vous, est-ce que ce test confirme la règle du ["First link counts"](http://moz.com/blog/results-of-google-experimentation-only-the-first-anchor-text-counts) ?

