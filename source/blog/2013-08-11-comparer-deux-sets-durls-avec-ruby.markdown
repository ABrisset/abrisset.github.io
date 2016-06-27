---
title: "Comparer deux sets d'URLs avec Ruby"
title_seo: "Comparer deux sets d'URLs avec Ruby"
description: "Un exemple de script Ruby pour rendre plus facile la mise en place de redirections SEO lors d'une migration, à travers la comparaison des slugs d'URLs."
date: 2013-08-11
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: "Dans le cadre d'une refonte, souvent, les URLs d'un site sont modifiées et générées selon de nouvelles règles : ajout de répertoires, modification du séparateur d'URL, renommage de catégories, etc. Cela oblige donc à créer tout un paquet de redirections, afin d'assurer une transition correcte en termes de PR, d'indexation et de trafic moteur. Je vous propose ici un petit script Ruby, qui vous permettra de préparer le terrain en matchant vos anciennes URLs avec les nouvelles..."
author:
---

## Préparer les deux jeux d'URLs

Dans un premier temps, il faut collecter toutes les URLs existantes. Pour faire cela, plusieurs méthodes complémentaires : crawl du site, scraping des pages indexées par Google, export des landing pages les plus stratégiques via Google Analytics, etc. Regroupez toutes ces URLs dans un fichier, dédoublonnez, et sauvegardez en CSV.

En parallèle, crawlez le nouveau site, avec votre outil homemade ou une solution comme Screaming Frog, et exportez toute les URLs dans un deuxième fichier. Glissez les deux fichiers dans un répertoire commun. Vous voilà prêt pour la suite.


## Place au script

L'objectif du script est de décomposer chaque URL du premier fichier (anciennes URL), en ne conservant que le slug, puis de comparer chaque slug à chaque URL du deuxième fichier, afin de déterminer quelles sont les URLs du nouveau site qui contiennent des caractères communs avec chacun de ces slugs.

### Première étape : extraire les URLs du CSV et les placer dans un array

Pour commencer, il faut faire appel aux gems CSV et URI qui vous permettront de manipuler les fichiers CSV ainsi que les URLs comme vous le souhaitez.

``` ruby
#!/usr/bin/env ruby

require 'csv'
require 'uri'
```

Ensuite, il faut extraire chaque URL des fichiers CSV et les placer dans un array. Pour cela, on utilise la méthode "reduce" dont j'ai déjà parlé dans un article sur le [scraping](http://www.antoine-brisset.com/blog/ruby-scraping/).

``` ruby
def select_first_array_elem(array)
	array.reduce([]) do |result, elem|
		result << elem.first
	end
end
```

### Deuxième étape : réduire chaque URL à son slug

Pour cela, nous allons définir une fonction utilisant "split". Cette méthode permet de découper une string sur la base d'un délimiteur spécifique. Dans le cas d'une URL, le délimiteur choisi sera donc le "/". En sortie, un array sera généré avec chacun des éléments. Dans notre cas, c'est uniquement la dernière partie de l'URL, le slug, qui nous intéresse. Nous allons donc sélectionner ce dernier élément de l'array avec un ".last".

Pour rendre plus propres les URLs, nous allons ensuite utiliser la méthode "slice!" qui permet, à partir d'une string, de retourner une nouvelle string, dont on a supprimé certains caractères. Ici, on utilise comme argument une regexp qui matche toutes les extensions possibles : html, gif, png, jpg, etc.

``` ruby
def split_url(url)
	result = url.split('/').last
	result.slice!(/.html|.gif|.jpg|.png/)
	result
end
```

### Troisième étape : comparer chaque slug avec les nouvelles URLs

Dans cette partie, nous allons définir une fonction permettant, concrètement :

* de prendre le slug de chaque URL du premier fichier
* de le comparer à chaque URL du deuxième fichier
* de créer un tableau avec l'URL du 1er fichier et la (ou les) correspondance(s) trouvée(s) dans le 2ème fichier

``` ruby
def included_in(array_1,array_2)
 	# on initialise le tableau de sortie
  results = Array.new(0)
	# on décompose chaque URL du fichier contenant les anciennes URLs
	array_1.each do |old_url|
		# on crée une variable avec l'host de de l'url
		host = URI.parse(old_url).host
		# on extrait le slug de l'URL
		slug = split_url(old_url)
		# on vérifie que l'URL n'est pas égale à la racine
		if old_url != "http://#{host}"
			# on vérifie que le slug fait plus de 1 caractère
			if slug.length > 1
				# on boucle sur chaque URL du fichier contenant les nouvelles URLs
				array_2.each do |new_url|
					# on crée de nouvelles variables uniquement si les nouvelles URLs "contiennent" la variable "slug"
					if new_url.include?(slug)
						url_from	= old_url
						status		= "matches"
						url_to		= new_url
					end
					# on remplit le tableau avec ces variables
					results << [url_from,status,url_to]
				end
			end
		end
	end
  # on retourne le tableau dédoublonné
	results.uniq
end
```

Comme vous le voyez, j'utilise ici une méthode très pratique, [include?](http://ruby-doc.org/core-2.0/Array.html#method-i-include-3F) qui permet de vérifier si un objet passé en argument est présent dans l'objet sur lequel on effectue le test.

### Quatrième étape : exporter les résultats dans un fichier CSV

Pour terminer, on construit un fichier CSV. Pour cela, nous allons donc utiliser la méthode CSV.
Chaque ligne du tableau contiendra l'URL source, la mention "matches" et l'URL vers laquelle rediriger.

``` ruby
def write_data_to_csv(path, data)
  CSV.open(path, "wb") do |csv|
  	csv << ["URL From", "Status", "URL To Redirect"]
  	data.each do |elem|
  		csv << elem
		end
	end
end
```

Il ne reste plus qu'à déclarer le chemin des fichiers et à utiliser nos différentes fonctions.

``` ruby
# chemin vers le fichier de résultats
file_path	    = "./results.csv"

# création d'un array avec les fichiers d'entrées (anciennes URLs, nouvelles URLs)
arr_of_arrs		= CSV.read("./array_1.csv")
arr_of_arrs_2	= CSV.read("./array_2.csv")

# sélection de la première colonne de chaque fichier d'entrée (URLs)
array_1 			= select_first_array_elem(arr_of_arrs)
array_2 			= select_first_array_elem(arr_of_arrs_2)

# création d'un array sur la base des slugs du fichier array_1 retrouvés dans array_2
union 				= included_in(array_1.uniq,array_2.uniq)

# export en CSV
write_data_to_csv(file_path, union)
```

Et voilà, si vous êtes sous Apache, vous n'avez plus qu'à faire un rechercher/remplacer avec "RewriteRule" et les flags 301 qui vont bien :)
