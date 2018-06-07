---
title: Récupérer les paramètres à partir d'une liste d'URLs avec Ruby
title_seo: "Récupérer Paramètres d'URL d'une Liste de Pages avec Ruby"
description: "Découvrez comment récupérer facilement les paramètres d'une liste d'URL. Un petit script Ruby Utile pour vos optimisations techniques SEO !"
date: 2018-06-07 14:33:56 +0200
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: Manipuler de longues listes de mots-clés ou de longues listes d'URL fait partie du quotidien d'un référenceur. Et quand on a des traitements récurrents à faire sur ces fichiers, on cherche souvent à automatiser. Un exemple ici avec l'extraction des paramètres depuis une liste d'URLs.
author:
slug: /params-url-ruby
---

Vous avez une liste d'URLs issue d'un crawl, d'une analyse de logs ou d'un export de backlinks et vous cherchez à identifier rapidement quels sont les différents paramètres d'URL présents ? Voici comment faire.

## L'intérêt SEO

Les applications sont nombreuses : identifier des paramètres générant du duplicate d'URL, trier les paramètres à autoriser/interdire au crawl ou à l'indexation, vérifier qu'il n'y a pas de problèmes de casse avec certains paramètres en minuscules et d'autres en majuscule, etc.

## La méthode en Ruby

Voilà un petit script pour automatiser le processus avec Ruby.

### Récupérer les paramètres

Pour récupérer les différents paramètres à partir de la liste, on va boucler sur cette liste et découper l'URL chaque fois qu'on trouve un "?" ou un "&". Chaque valeur sera stockée dans un array. On va ensuite retirer de notre array le 1er élement (l'URL sans les paramètres) via la méthode `drop`. Puis supprimer de l'array les éléments vides, et, pour chaque valeur, supprimer tout ce qui se trouve derrière le "=". On va mettre à plat notre array avec `flatten`.

``` ruby
#!/usr/bin/env ruby

def get_params_from(list)
  list.map do |url|
    url.split(/\?|\&/).
        drop(1).
        reject(&:empty?).
        map { |param| param.sub!(/=.*/,"") }
  end.flatten
end
```

### Compter les occurrences de chaque paramètre

Une fois qu'on a notre liste de paramètres, on va compter le nombre de fois où chaque paramètre apparait.
On va utiliser pour cela la méthode `inject` qui permet d'instancier un mémo (ici un hash) qu'on remplit lors de notre loop avec un simple comptage.

``` ruby
def count_params_from(list)
  list.inject(Hash.new(0)) { |h, i| h[i] += 1; h }
end
```

### Stocker le tout dans un CSV

Il ne reste plus qu'à exporter le tout dans un CSV.

``` ruby
def export_to_csv(data)
  CSV.open("params.csv", "w") do |file|
    data.each do |value|
      file << [value]
    end
  end
end
```

### Le code complet

Amusez-vous bien :)

``` ruby
#!/usr/bin/env ruby

require 'CSV'

def get_params_from(list)
  list.map do |url|
    url.split(/\?|\&/).
        drop(1).
        reject(&:empty?).
        map { |param| param.sub!(/=.*/,"") }
  end.flatten
end

def count_params_from(list)
  list.inject(Hash.new(0)) { |h, i| h[i] += 1; h }
end

def export_to_csv(data)
  CSV.open("params.csv", "w") do |file|
    data.sort_by { |k, v| v }.reverse.each do |k, v|
      file << [k,v]
    end
  end
end

list = CSV.read("./urls.csv").flatten
params = get_params_from(list)
params_hash_count = count_params_from(params)
export_to_csv(params_hash_count)
```