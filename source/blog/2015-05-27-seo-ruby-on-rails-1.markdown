---
title: "Bonnes pratiques SEO sous Ruby on Rails - 1ère partie"
title_seo: "SEO Ruby on Rails : bonnes pratiques (1ère partie)"
description: "Découvrez dans ce premier article quelques astuces pour optimiser le référencement de votre application Ruby on Rails"
date: 2015-05-27
hero_image: train.jpg
thumbnail:
category: "SEO On-site"
excerpt: "Après avoir passé quelques années à bidouiller des petits scripts en Ruby, je me suis lancé l’année dernière dans l’apprentissage de Ruby on Rails, grâce notamment à <a href='http://www.amazon.fr/Ruby-Rails-4-0-Guide-guide/dp/1491054484/?_encoding=UTF8&camp=1642&creative=6746&linkCode=ur2&tag=antoine-brisset-21'>ce livre de Stefan Wintermeyer</a>, que je recommande d’ailleurs vivement à tous ceux qui seraient désireux d’apprendre les bases de RoR. N’étant pas développeur de formation, ce framework est pour moi vraiment intéressant dans le sens où il permet de développer rapidement et sans trop de prise de tête des applications plus ou moins complexes. Ayant suffisamment de recul sur le fonctionnement de Rails, je vous propose une série d’articles sous forme d’astuces pour optimiser les fondamentaux SEO de votre application Ruby on Rails. C’est parti pour la 1ère partie !"
author:
---

## Réécriture d'URL

Par défaut, Rails utilise la clé primaire id pour la génération des URL. Par exemple, s'il reçoit une requête de type GET /photos/3, le fichier routes.rb va transmettre la requête au controller "photos_controller", en passant en paramètre à l'action "show" la valeur de l'id. Rails va donc être en mesure de retrouver l'objet associé en recherchant dans le modèle "Photo" l'objet ayant pour id "3".

Cela fonctionne très bien, certes, mais ce n'est pas optimal d'un point de vue SEO. Si j'ai tendance à considérer que l'ajout de mots-clés dans l'URL n'est pas impératif en termes de ranking, je pense néanmoins que dans les SERP, avoir le mot-clé en gras au lieu d'un simple id est un petit plus visuel qui peut booster votre CTR.

Alors, comment faire pour rendre les URL plus sexy ? Une première solution pourrait être de surcharger la méthode to_param, qui, grosso modo, gère la construction des chemins d'URL. Quelque chose de ce type, dans le modèle :

``` ruby
def to_param
  "#{id}-#{name.parameterize}"
end
```

Dans le cas où notre table photos dispose d'une colomne "name", les URL générées pour chaque objet photo reprendront l'id, suivi du nom, lequel aura été débarrassé de tout caractère spécial, via la méthode "parameterize".

C'est une solution intéressante mais qui présente un gros défaut : avant de lancer la requête SQL lui permettant de rechercher à quel objet correspond l'id reçu en paramètre, Rails va convertir cet id en entier via la méthode to_i. Ce qui signifie, par exemple, que "1-toto" va devenir "1". Vous voyez où je veux en venir ? Si quelqu'un s'amuse à générer des URL de type "1-lolilol" ou "1-trololo", Rails va quand même renvoyer l'objet ayant pour id "1" et afficher la page, laissant la porte ouverte à des attaques de negative SEO à coup de duplicate d'URL.

Je vous conseille donc d'utiliser un système plus robuste, qui se débarrassera complètement de l'id et reposera sur un autre attribut du modèle. Par exemple, dans le cas de notre modèle Photo, l'attribut name. On pourrait faire cela "à la main" :

- on ajoute un nouvel attribut à notre modèle, par exemple "slug" (il faut prévoir la migration de la base)

``` console
rails g migration AddSlugToPhotos slug:string
rake db:migrate
```
- on l'ajoute à notre liste de paramètres autorisés, au niveau du controller

``` ruby
def photo_params
  params.required(:photo).permit(:name, :slug)
end
```
- on valide sa présence lors de chaque nouvel item créé, au niveau du modèle

``` ruby
validates :slug, presence: true, uniqueness: true
```
- on modifie la la méthode to_param, au niveau du modèle

``` ruby
def to_param
  slug
end
```
- pour chaque appel à la méthode find, il faudra désormais utiliser la méthode "find_by_slug" et non plus "find", puisque cette dernière recherche les enregistrements de la base de données par id.

Pour aller beaucoup plus vite, dans cet esprit, il existe une gem très complète : [friendly_id](https://github.com/norman/friendly_id). Une fois la gem installée, il suffit de d'ajouter les méthodes de la classe FriendlyId à notre modèle

``` ruby
extend FriendlyId
```
Puis de spécifier quel attribut sera utilisé pour la génération du slug (ici, "name")

``` ruby
friendly_id :name, use: :slugged
```

Et enfin, de remplacer la méthode *find* par *friendly.find*, chaque fois que vous l'utilisez dans vos vues et/ou controllers.

Et voilà ! On se retrouve avec de belles URL contenant nos mots-clés. Petite précision concernant les URL sous Rails : par défaut Rails utilise les cookies pour stocker les infos de session. Donc a priori, vous n'aurez jamais de souci avec des id de session présents dans les URL qui pourraient créer du duplicate d'URL.

## Balises title & meta

Le contenu de la balise title est l'un des critères SEO les plus importants, c'est d'ailleurs [un consensus auprès des référenceurs](http://www.seo-factors.com/fr/). Dans une application Ruby on Rails, il faut donc disposer a minima d'un système permettant de personnaliser les balises title et meta (description, robots) pour chaque page / template.

Pour faire cela proprement et simplement, on pourrait par exemple s'aider d'une méthode qu'on ajouterait dans le helper de l'application. L'idée étant de ne pas surcharger nos vues. Par exemple, on pourrait ajouter une méthode telle que celle-ci dans notre fichier application_helper.rb

``` ruby
def title(title_content)
  if title_content.present? # si le paramètre title_content est présent
    title_content << " | Mon Site" # le title reprendra la chaîne en paramètre suivie de " | Mon Site"
  else
    "Mon Site" # sinon, par défaut, le title sera "Mon site"
  end
end
```

Dans le layout de l'application, il faudrait donc dynamiser cette partie (ici sous slim) :

``` ruby
title
  = yield(:title)
```

Puis, dans chaque vue, utiliser la méthode content_for qui fera appel à notre helper, de cette manière :

``` ruby
= content_for :title, title("Mon titre avec mots-clés")
```

Vous pourriez vous inspirer de ce helper pour gérer, de la même façon, les balises meta description et meta robots.

<u>MAJ du 01/06/2015</u>

Suite à cet [excellent article](http://www.lewagon.org/blog/tuto-setup-metatags-rails) publié par le Wagon, je vous conseille de définir les valeurs par défaut de vos balises meta dans un fichier yaml à placer directement dans le dossier config/initializers (exemple: meta.rb)

``` yaml
default_title: "Mon Site"
```

Puis de charger celui-ci dans le fichier environnement.rb :

``` ruby
DEFAULT_META = YAML.load_file(Rails.root.join('/config/meta.yml'))
```

Ce qui vous permettra, dans votre helper, de faire la chose suivante :

``` ruby
def title(title_content)
  if title_content.present?
    title_content << " | " + DEFAULT_META['title']
  else
    DEFAULT_META['title']
  end
end
```

Si vous souhaitez faire plus simple (ou aller plus vite, à vous de voir), je vous conseille d'utiliser la gem [meta_tags](https://github.com/kpumuk/meta-tags). Elle permet de définir et de personnaliser vos balises title, meta, open graph, twitter cards, hreflang et bien d'autres, que ce soit au niveau de votre controller ou au niveau de votre vue. Un outil vraiment très bien pensé, intuitif, qui vous rendra service si vous souhaitez optimiser dans le détail toutes ces balises sans réinventer la roue.

Si je reprends mon modèle Photo, et que je souhaite par exemple définir les title et meta description de chaque item Photo, voici comment je devrai procéder :

- d'abord, ajouter la méthode dans le layout de l'application

``` ruby
display_meta_tags :site => 'Mon Site', :reverse => true, :separator => "|"
```

- puis setter les bonnes variables dans le controller photos_controller#show

```ruby
def show
  @photo = Photo.friendly.find(params[:id])
  set_meta_tags :title => '@photo.name',
                :description => '@photo.name : découvrez ma jolie photo !',
                :robots => 'index, follow'
end
```

## Robots.txt

Le fichier robots.txt est un fichier tout bête à première vue et pourtant, c'est celui pour lequel Googlebot a le plus d'appétance. En effet, c'est dans celui-ci que sont contenues les directives de crawl de votre site. Une erreur de syntaxe, et ça peut être la catastrophe !

Pour la gestion de ce fichier, plusieurs options sont possibles sous Rails.

### 1ère option

Tout d'abord, vous pouvez créer ce fichier et le placer dans le dossier public de votre application. Il sera alors disponible directement à la racine de votre site. Oui, mais problème : pour chacun de vos environnements, le contenu de ce fichier sera le même. Donc si en prod, vous avez un joli

``` text
User-Agent: *
Allow: /
```

... alors votre environnement de préprod contiendra les mêmes directives et risquera de se faire crawler et donc indexer, dans l'éventualité bien sûr où celui-ci n'est pas protégé par authentification (login / mot de passe). Pas top donc. Passons à la 2ème option.

### 2ème option

La 2ème option est de loin la meilleure, mais elle nécessite un peu plus de travail. En effet, nous allons utiliser un controller spécifique qui interceptera toutes les requêtes de type GET /robots.txt. Pour cela, commençons par mettre à jour notre fichier routes.rb

``` ruby
get '/robots.:format' => 'pages#robots'
```

Ici, nous allons transmettre la requête à un controller "pages" et plus spécifiquement à l'action "robots". Voyons voir le contenu de notre méthode robots :

``` ruby
def robots
  respond_to :text
end
```
Rien de bien sorcier, elle s'occupe simplement de "répondre" à la requête en renvoyant un contenu au format texte.
Passons à notre vue, rendez-vous dans views > pages > robots.text.slim. C'est ici que ça devient intéressant. Car, oui, nous allons pouvoir dynamiser notre fichier robots.txt, c'est-à-dire renvoyer un contenu différent selon que l'on soit sur l'environnement de production ou sur l'environnement de développement / staging / recette.

``` ruby
- if Rails.env == "production"
  = "User-Agent: *\n"
  = "Disallow: /admin"
- else
  = "User-Agent: *\n"
  = "Noindex: /"
end
```

Grâce à cette astuce, vous maîtrisez parfaitement votre indexation sur chacun de vos environnements !

La suite des astuces d'optimisation de votre référencement naturel sous Ruby on Rails, c'est [ici](http://www.antoine-brisset.com/blog/seo-ruby-on-rails-2/) !
