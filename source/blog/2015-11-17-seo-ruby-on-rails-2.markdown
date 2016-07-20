---
title: "Bonnes pratiques SEO sous Ruby on Rails - 2ème partie"
title_seo: "SEO Ruby on Rails : bonnes pratiques (2ème partie)"
description: "Découvrez, dans ce deuxième article, de nouvelles pistes d'optimisation SEO pour votre application Ruby on Rails ! Au programme : redirection www, sitemap.xml et erreur 404..."
date: 2015-11-17 10:46:00 +0100
hero_image: train.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Dans le <a href='http://www.antoine-brisset.com/blog/seo-ruby-on-rails-1/'>1er article sur les bonnes pratiques SEO sous Ruby on Rails</a>, nous avons vu comment avoir des URL propres, optimiser ses balises title & meta et éditer facilement son fichier robots.txt. Voyons aujourd'hui comment forcer un domaine canonique (www), construire un fichier sitemap.xml et définir une page d'erreur 404 personnalisée."
author:
alias: bonnes-pratiques-seo-sous-ruby-on-rails-2eme-partie/
---

## Forcer la redirection vers www

Si vous souhaitez forcer la redirection permanente vers le sous-domaine www de votre site, vous pouvez, au choix, ajouter la directive qui va bien au niveau du serveur, ou demander à votre application de faire le travail. Dans votre fichier `routes.rb`, il suffit d'ajouter la contrainte suivante :

``` ruby
constraints(host: /^(?!www\.)/i) do
  match '(*any)' => redirect { |params, request|
    URI.parse(request.url).tap { |uri| uri.host = "www.#{uri.host}" }.to_s
  }
end
```

Concrètement, la méthode vérifie au travers de l'expression rationnelle `^(?!www\.)/i`, que ce qui apparait immédiatement au début de la chaine de caractères composant le host n'est pas "www.", c'est-à-dire que la requête a été envoyée sans les www.

Si c'est bien le cas, la requête est capturée dans la méthode `match` puis passée à la méthode `redirect` qui va générer la redirection 301 vers la bonne URL. Cette méthode prend en argument les éventuels paramètres d'URL, ainsi que l'objet `request` et retourne en sortie une chaîne de caractères.

Pour obtenir cette chaîne, un nouvel objet `URI` est instancié, auquel est passé en paramètre l'URL de la requête. Son attribut host, enfin, est modifié en y ajoutant les "www." grâce à la méthode `tap`.
Et voilà, plus de problème de duplicate d'URL !


## Créer un sitemap.xml

L'utilité d'un sitemap.xml est [controversée](http://www.creapulse.fr/le-sitemap-xml-cest-pas-bon-pour-le-seo/) mais reste un bon moyen, néanmoins, de faire connaître rapidement à Googlebot les nouvelles pages de son site.


### 1ère option : utiliser la gem Dynamic Sitemaps

Pour mettre en place un sitemap.xml avec Ruby on Rails, il existe plusieurs gems vraiment pratiques telles que [Dynamic Sitemaps](https://github.com/lassebunk/dynamic_sitemaps). Cette gem permet de définir plusieurs sitemaps, comme par exemple un premier sitemap regroupant des pages statiques et un second sitemap listant les items d'un modèle. Elle permet également de définir le last_mod, de fixer des priorités de crawl et même de pinguer les moteurs de recherche chaque fois que le sitemap est mis à jour !

Prenons l'exemple d'un blog qui contient une série d'articles construits à partir du modèle `Article`, sur lequel a été défini un scope `published`, autrement dit :

``` ruby
class Article < ActiveRecord::Base
  scope :published, -> { where( published: true ) }
end
```

Il est alors très facile avec *Dynamic Sitemaps* de générer le sitemap des articles, en créant le fichier `sitemap.rb` suivant dans le dossier `config` :

``` ruby
# on indique le domaine racine
host "www.example.com"

# à ajouter seulement si vous votre site utilise le protocole https
protocol "https"

# on boucle sur les articles
sitemap_for Article.published, name: :articles do |article|
  url article, last_mod: article.updated_at
end

# on pinge Google
ping_with "http://#{host}/sitemap.xml"

```

Pour générer le sitemap, il suffit, en console, de lancer la commande suivante :

``` console
$ rake sitemap:generate
```

Ou d'utiliser [la gem Whenever](http://www.antoine-brisset.com/blog/cron-job-whenever/) dont j'ai déjà parlé pour créer une tâche cron qui sera chargée de rafraîchir le sitemap toutes les nuits par exemple.
Il est également possible de paramétrer pas mal d'options via un initializer, mais je vous laisse consulter [la doc](https://github.com/lassebunk/dynamic_sitemaps/blob/master/README.md) pour plus de détails.


### 2ème option : utiliser la librairie Builder::XmlMarkup

Parfois, néanmoins, il n'est pas possible d'utiliser ce type de gem, notamment lorsqu'on utilise un service de cloud comme [Heroku](https://www.heroku.com/), qui n'autorise pas l'écriture de fichiers. La solution est alors à chercher du côté de la librairie XML builder, qui met à notre disposition un ensemble de méthodes dédiées à la création d'un fichier xml.

Avant de construire notre fichier, il faut bien entendu mettre à jour le fichier `routes.rb` et lui indiquer à quel controller transmettre la requête. Et si nous utilisions notre controller `PagesController` ? Si vous vous souvenez du 1er article, nous l'avions utilisé pour le fichier robots.txt.

``` ruby
get '/sitemap.xml' => 'pages#sitemap', defaults: { format: 'xml' }
```

Dans le controller, nous allons définir les variables qui nous intéressent pour la construction du fichier sitemap. Reprenons l'exemple de notre application et de son modèle `Article` : dans notre méthode sitemap, nous créons une variable d'instance contenant l'ensemble des articles publiés et nous précisons que la réponse doit être au format xml :

``` ruby
class PagesController < ApplicationController

  def sitemap
    @articles = Article.published
    respond_to do |format|
      format.xml
    end
  end

end
```

Au niveau de la vue (dans views > pages > sitemap.xml.builder), il n'y a plus qu'à ajouter le prologue XML via `xml.instruct!`, d'ajouter la balise d'ouverture urlset via `xml.urlset` puis de boucler sur chacun des records.

``` ruby
xml.instruct!
xml.urlset(
  'xmlns'.to_sym => "http://www.sitemaps.org/schemas/sitemap/0.9",
) do
  @articles.each do |foodtruck|
    xml.url do
      xml.loc "#{article_url(article)}"
      xml.lastmod article.updated_at.strftime("%F")
    end
  end
```

Seul bémol : la page étant servie dynamiquement, le temps de chargement sera plus long lorsque Google viendra la consulter que si elle avait été générée en amont.


## Définir une page d'erreur 404

La page 404 est souvent la grande oubliée des projets de création ou de refonte de site. Elle est pourtant [recommandée par Google](https://support.google.com/webmasters/answer/93641?hl=fr). A ce titre, mais aussi et surtout pour des questions d'expérience utilisateur, il est nécessaire de pouvoir en proposer une sur son site.

Par défaut, Rails propose une page 404.html et une page 500.html qui se trouvent dans le dossier `public`, mais il s'agit de pages statiques qui ne reprennent pas le layout de notre application. On peut donc faire mieux, en optant pour quelque chose de dynamique.

Il est en effet possible au niveau de l'applicatif de définir une page 404 personnalisée. Encore une fois, la première étape consiste à modifier le fichier `routes.rb` afin de lui indiquer ce qu'il doit afficher en cas de page non trouvée. Créons un nouveau controller, pour ne pas surcharger le controller `PagesController`. Celui-ci s'appellera par exemple `ErrorsController`.

Par défaut, Rails s'attend à ce que la page d'erreur soit servie depuis la page /404. C'est donc celle-ci que nous allons cibler dans le fichier `routes.rb` :

``` ruby
get '/404' => 'errors#not_found'
```

Dans notre controller, ajoutons une méthode `not_found` qui se chargera d'envoyer le bon code retour :

``` ruby
class ErrorsController < ApplicationController

  def not_found
    render(:status => 404)
  end

end
```

<u>Les trois étapes restantes sont alors</u> :

* de modifier la page `not_found.html.slim` (si vous utilisez slim) afin d'afficher un message personnalisé qui reprendra le layout principal
* de supprimer la page 404.html dans le dossier `public`
* de demander à Rails d'utiliser les routes que nous avons déclarées plutôt que celles utilisées par défaut

``` ruby
config.exceptions_app = self.routes
```

Et voilà, il n'y a plus qu'à tester ! Bien entendu, vous pouvez vous inspirer de la méthodologie ci-dessus pour la gestion des erreurs 410, ou encore des erreurs 503. A noter, enfin, que si votre applicatif génère une erreur 500, peu importe l'URL demandée, il ne pourra pas exécuter les actions définies dans votre controller `ErrorsController`. Il n'est donc pas inutile de configurer votre serveur de manière à ce qu'il prenne le relais quand Rails est incapable de traiter une requête.

## Booster le temps de chargement avec Last-Modified

Petit bonus : si vous souhaitez améliorer vos temps de réponse et ainsi augmenter le nombre de pages crawlées par Google à l'intérieur d'une même fenêtre de crawl, voici comment gérer facilement vos requêtes HTTP conditionnelles pour renvoyer un maximum de codes 304 Not Modified. Car, oui, [Google utilise l'en-tête HTTP If-Modified-Since](https://support.google.com/webmasters/answer/35769?hl=fr) dans ses requêtes et il serait dommage de ne pas en tirer profit.

Reprenons l'exemple de notre blog et du modèle `Article`. Nous allons utiliser la méthode `fresh_when` suivie de l'argument `last_modified` dont la valeur correspondra à la date de dernière mise à jour de l'objet (`updated_at`), ce qui donne :

``` ruby
def show
  @article = Article.friendly.find(params[:id])
  fresh_when last_modified: @article.updated_at
end
```

Automatiquement, cette méthode va fixer la valeur de l'en-tête `Last-Modified` et déterminer, pour chaque requête, si un code 304 Not Modified doit être renvoyé : si la date de dernière modification de l'objet est inférieure à la date stipulée dans le `If-Modified-Since`, la requête est "fresh" (on renvoie un code 304 avec une réponse partielle), sinon elle est "stale" (on renvoie un code 200 avec la réponse complète).

Pour vérifier la bonne implémentation de la 304, vous pouvez lancer utiliser cURL en ligne de commande (changez la date et l'URL en fonction de ce que vous voulez tester):

``` console
curl -I -H "If-Modified-Since: Thu, 20 Jul 2016 21:00:00 GMT" http://www.antoine-brisset.com
```

J'espère que ces deux articles sur l'optimisation SEO de votre application Ruby on Rails vous auront plu. N'hésitez pas si vous avez des questions ou si vous souhaitez que je creuse un sujet en particulier.
