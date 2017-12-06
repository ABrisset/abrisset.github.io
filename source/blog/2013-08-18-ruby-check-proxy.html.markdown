---
title: "Tester la validité d'un proxy avec Ruby"
title_seo: "Tester un proyx avec Ruby"
description: "Vous avez besoin de savoir si vos proxies sont valides Google ? Testez les avec ce script Ruby."
date: 2013-08-18
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: "Pour ne pas se faire refouler par Google quand on lui envoie trop de requêtes en automatique, il est important de se munir de proxies. Mais encore faut-il qu'ils soient valides ! Qu'ils soient <a href='https://www.google.fr/search?q=fresh+proxies&amp;tbs=qdr:h'>publics</a> ou privés, l'important, c'est donc de pouvoir tester leur validité avant d'entamer toute action de scraping."
author:
slug: /ruby-check-proxy
---

Je vous propose donc un nouveau petit script Ruby, qui à partir, d'un array de proxies, vérifie s'ils sont valides Google ou non. Ce script utilise la librairie [Net::HTTP](http://ruby-doc.org/stdlib-2.0/libdoc/net/http/rdoc/Net/HTTP.html), pensez donc à ajouter ceci en début de fichier.

``` ruby
#!/usr/bin/env ruby

require 'net/http'
```

Commencez par définir une variable contenant vos proxies. Par exemple :

``` ruby
proxies = ["1.179.147.2:8080","1.93.21.147:2222","100.45.50.131:8080","101.109.251.140:80","101.109.251.140:8080"]
```

Voici ensuite la méthode utilisée (que j'ai nommée connectable), commentée pas à pas :

``` ruby
def connectable(array)
	# on crée un array vide qui nous servira à collecter les proxies valides
  results = Array.new(0)
  # on définit un block à partir de l'array
  array.each do |proxy|
  	# on découpe le proxy avec ":"
  	# on crée ainsi les variables host et port à partir des deux éléments
    host, port = proxy.split(':')
    # on démarre un block begin/end
    begin
    	# on crée un nouvel objet HTTP utilisant les paramètres du proxy
    	# la session n'est pas encore ouverte
      http              = Net::HTTP::Proxy(host, port).new('www.google.fr')
      # on définit un timeout de 0,5 secondes pour la connexion
      http.open_timeout = 0.5
      # on définit un timeout de 0,5 secondes pour le chargement
      http.read_timeout = 0.5
      # on ouvre la session avec la méthode start
      http.start do |connect|
      	# on récupère la réponse HTTP d'une requête "site:example.com" sur Google
        response = connect.head('/search?safe=off&hl=fr&q=site:example.com')
        # on définit un comportement spécifique en fonction de la réponse
        case response
        # si le code retour apartient à la classe Net::HTTPOK (code 200)
        when Net::HTTPOK
        	# on stocke le proxy utilisé dans l'array results
          results << proxy
        end
      end
    rescue
    	# si la connexion est impossible, on retourne nil
      nil
    end
  end
  # on affiche les proxies valides dans la console
  puts results
end
```

Concrètement, l'objectif est d'ouvrir une connexion sur www.google.fr, en passant à travers chaque proxy de l'array, puis d'effectuer une requête assez "sensible" en utilisant la commande "site:". Si le code réponse renvoyé par Google est 200, le proxy est considéré valide donc on le stocke, sinon on passe au suivant.

Libre à vous de jouer sur les temps de timeout en fonction de votre tolérance aux performances des proxies. Pour améliorer ce script, vous pouvez également exporter le tout dans un fichier CSV.

Pour exécuter la méthode, ajoutez simplement à la fin de votre fichier .rb :

``` ruby
connectable(proxies)
```

A vous de jouer !
