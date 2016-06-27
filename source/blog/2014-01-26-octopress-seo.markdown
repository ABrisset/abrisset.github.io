---
title: "Octopress : 10 conseils d'optimisation SEO"
title_seo: "SEO Octopress : 10 conseils d'optimisation"
description: "10 astuces pour optimiser votre blog Octopress. Balises meta, title, canonique... mettez toutes les chances de votre côté pour un bon référencement."
date: 2014-01-26
hero_image: on-site.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Si <a href='http://octopress.org/'>Octopress</a> est incomparable en termes de performances, il présente quelques lacunes quant à l'optimisation pour le référencement. Je vous propose donc dans cet article 10 astuces simples à mettre en place pour rendre le framework plus SEO friendly"
author:
---

## 1. Ajouter une meta description dans les posts

Par défaut, lorsque vous créez un nouveau post, le bloc YAML qui contient les variables propres à chaque article ne vous donne pas la possibilité de mapper une meta description. Pour corriger le tir, il suffit de modifier le fichier Rakefile en forçant l'ajout de la description à chaque création de post :

``` ruby
open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "description: "
    post.puts "---"
  end
```

Désormais, à chaque fois que vous exécuterez la commande **rake new_post['mon titre']**, le champ "description:" sera présent dans votre YAML et vous pourrez ainsi définir une meta description personnalisée.
Vous pouvez faire la même chose avec la balise meta keywords. A vous de voir si ça vaut le coup ;)

## 2. Customiser les balises title et meta description de la homepage

Pour définir une balise title sur la homepage, rendez-vous dans le fichier _config.yml et remplissez le champ title, juste en dessous du champ "url" :

``` yaml
# ----------------------- #
#      Main Configs       #
# ----------------------- #

url: http://blog.antoine-brisset.com
title: Blog Référencement & Astuces SEO &bull; A. Brisset
```

Passons à la meta description. Par défaut, sur la homepage, Octopress reprend la meta description du dernier post, tronquée à 150 caractères. Pour corriger cela, deux étapes :

* tout d'abord, éditez le fichier head.html dans source > _includes > post et remplacez les quelques lignes concernant la meta description par les suivantes :

``` code
{% capture description %}
{% if page.description %}{{ page.description }}{% elsif site.description %}{{ site.description }}{% endif %}
{% endcapture %}
<meta name="description" content="{{ description }}" >
```

* ensuite, éditez le ficher _config.yml, en complétant le champ description :

``` yaml
author: Antoine Brisset
simple_search: http://google.com/search
description: Ma jolie description pour booster mon fucking CTR !
```

Et voilà, votre homepage affichera en title et meta description le contenu renseigné dans le fichier _config.yml !


## 3. Corriger le bug de génération de la balise canonique


C'est en parcourant le compte [Webmaster Tools](http://www.antoine-brisset.com/blog/mots-cles-webmaster-tools/) de mon propre blog Octopress que je me suis rendu compte d'un bug sur la gestion de la balise canonique, en analysant plus précisément la prise en compte de mon sitemap.
Pour bien comprendre le problème, il faut revenir un instant sur le fonctionnement d'Octopress et notamment sur la génération des pages statiques. Trois remarques importantes :

* lorsqu'on lance la commande **rake generate**, chaque post est créé sous la forme d'un fichier index.html contenu dans un dossier reprenant le titre du post. Dès lors qu'on accède à ce répertoire, le serveur charge donc par défaut le fichier index.html qu'il contient

* dans le maillage interne, chaque lien généré dispose d'un slash de fin

* toute requête vers l'URL sans le slash de fin est redirigée en 302 vers cette URL avec le slash de fin

Or, dans le fichier head.html, contenu dans source > _includes > post, la balise canonical reprend l'URL du post, mais le fameux "trailing slash" est **supprimé** !

``` code
{% capture canonical %}{{ site.url }}
{% if site.permalink contains '.html' %}{{ page.url }}
{% else %}{{ page.url | remove:'index.html' | strip_slash }}
{% endif %}
{% endcapture %}
```

Sur mon blog, en me rendant dans la section "exploration > sitemaps", je me suis rendu compte qu'une seule URL, en l'occurence la homepage, était indexée. Pour cause : les URL du sitemap contenaient un slash de fin, mais les URL canoniques non.

**Conclusion** : Google indexait les URL canoniques et non celles du sitemap, qui étaient redirigées en 302 vers les URL avec slash... bref une abbération SEO.

Pour résoudre ce problème, il suffit simplement de remplacer dans votre fichier head.html

``` code
{% else %}{{ page.url | remove:'index.html' | strip_slash }}
```

par

``` code
{% else %}{{ page.url | remove:'index.html' }}
```

Pour l'anecdote, depuis que j'ai corrigé ce bug, toutes mes URL de posts déclarées en sitemap sont indexées par Google.


## 4. Exclure certaines pages du sitemap

Dans le sitemap figurent par défaut certaines URL du dossier public qui n'ont rien à y faire :

* la page 404

* le ficher robots.txt

Rendez-vous donc dans plugins > sitemap_generator.rb et ajoutez les fichiers à exclure dans le array prévu :

``` ruby
module Jekyll

  # Change SITEMAP_FILE_NAME if you would like your sitemap file
  # to be called something else
  SITEMAP_FILE_NAME = "sitemap.xml"

  # Any files to exclude from being included in the sitemap.xml
  EXCLUDED_FILES = ["atom.xml","404.markdown","robots.txt"]
```


## 5. Activer l'authorship

Pour associer votre blog à votre profil Google+, éditez votre fichier _config.yml, en ajoutant l'id de votre profil, suivi du paramètre ?rel=author. Si vous avez ajoutez l'URL de votre blog sur votre profil Google+, dans la section "Également auteur de :", vous devriez rapidement voir apparaitre [l'authorship](https://support.google.com/webmasters/answer/1408986?hl=fr) dans les SERP.

Je vous conseille de tester d'abord avec cet outil http://www.google.com/webmasters/tools/richsnippets pour vérifier si Google parvient à extraire les informations correctement.


## 6. Raccourcir le slug des posts

Par défaut, la date de publication est reprise dans les permaliens. Vous pouvez supprimer cette date et ne garder que le titre. Changez ceci dans le _config_yml :

``` yaml
permalink: /:title/
```


## 7. Augmenter le nombre de posts par page

Pour éviter les paginations à rallonge, vous pouvez augmenter le nombre d'articles par page, en le fixant par exemple à 15. Cela se passe encore une fois dans le _config.yml :

``` yaml
paginate: 15  # Posts per page on the blog index
```

## 8. Ajouter les attributs rel="next" / rel="prev"

Pour permettre à Google de mieux identifier les relations entre vos pages de pagination, vous pouvez ajouter les attributs rel next et rel prev sur celles-ci. Vos pages de pagination seront alors interprétées comme une séquence logique et les différents signaux reçus par ces pages seront consolidés. Dans le dossier source, éditez le fichier index.html de la façon suivante :

``` code
  <div class="pagination">
    {% if paginator.next_page %}
    <a class="prev" rel="next" href="{{paginator.next_page}}">&larr; Précédent</a>
    {% endif %}
    {% if paginator.previous_page %}
    <a class="next" rel="prev" href="{{paginator.previous_page}}">Suivant &rarr;</a>
    {% endif %}
  </div>
```

## 9. Customiser la page 404

Pour définir une 404 personnalisée, il vous suffit de vous rendre dans source > 404.markdown et d'éditer le contenu, en ajoutant par exemple un lien retour vers l'accueil, ou un lien vers vos meilleurs articles.

## 10. Ne pas oublier d'utiliser le "more"

Enfin, dernière astuce, lors de la saisie de vos contenus markdown, n'oubliez pas d'utiliser le commentaire "more" :

``` html
<!-- more -->
```

Celui-ci permettra de réduire le contenu dupliqué en page d'accueil ou en page catégorie, en n'affichant qu'un simple extrait de votre article, et non sa version complète.

## Bonus : ajouter une balise meta robots noindex à un post

Si vous désirez ne pas indexer un article (ça peut arriver), éditez votre fichier head.html et ajoutez la ligne suivante, par exemple sous la meta description

``` code
{% if page.robots %}<meta name="robots" content="{{ page.robots }}">{% endif %}
```

Dans l'en-tête YAML de votre post, il suffira alors de préciser quand c'est nécessaire les valeurs que vous souhaitez, par exemple "noindex, follow"

``` yaml
robots: noindex, follow
```

Ca y est, vous voilà armés pour optimiser le référencement de votre blog sous Octopress. Si vous avez d'autres pistes d'optimisations, n'hésitez pas à les signaler en commentaires. Et si vous voulez vous mettre à Octopress, je vous conseille de commencer par la lecture de [ces basiques](http://octopress.org/docs/blogging/).
