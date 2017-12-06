---
title: "Créer une tâche cron SEO avec Whenever, Mail et Amazon EC2"
title_seo: "Cron job Amazon EC2 avec Whenever & Mail"
description: "Utilisez la puissance d'Amazon EC2 pour vous créer des petites tâches cron et vous facilier le SEO au quotidien. Je vous livre ici un tuto détaillé !"
date: 2013-11-12
hero_image: train.jpg
thumbnail:
category: "Scripts SEO"
excerpt: "Quand on bosse le SEO d'un site, on est souvent amené à corriger des petits bugs, bien souvent après qu'ils se soient déclarés. En automatisant certaines tâches, de manière quotidienne ou hebdomadaire, on peut être alerté plus rapidement des éventuels problèmes ou mettre en place un système de monitoring sur certaines données."
author:
slug: /cron-job-whenever
---

Je vous propose donc ici un exemple de tâche cron vous permettant de suivre au travers d'un mail quotidien le nombre de pages de votre site indexées par Google.
Pour ce faire, j'utiliserai les gems *Mail*, *Whenever* et *Nokogiri*. Le script sera lancé depuis une instance Linux d'[Amazon EC2](http://aws.amazon.com/fr/ec2/), un des outils cloud de l'offre **AWS** que je ne peux que recommander pour sa souplesse d'utilisation. D'autant qu'EC2 est gratuit pendant un an, à hauteur de 750 heures d'utilisation par mois. Si vous souhaitez installer proprement Ruby et les principaux utilitaires sur votre machine distance, je vous invite à suivre [ce court tutoriel](https://github.com/bvmake/WhosGotWhat/wiki/Installing-Rails-on-free-Amazon-EC2-Micro).

## Scraper le nombre de résultats de la commande site:

Pour commencer, il nous faut la méthode qui permettra de scraper le nombre de résultats Google retournés par la commande site:nomdusite.com. Celle-ci prendra en argument une URL, exécutera la requête site:nomdusite.com sur Google.fr et retournera le résultat sous forme de string. Avant de commencer, il faut faire appel aux différentes gems dont on aura besoin.

``` ruby
#!/usr/bin/env ruby

require 'mail'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'rubygems'
require 'timeout'
```

Si vous avez installé bundler sur votre serveur Linux, pensez à déclarer ces dépendances dans votre Gemfile et à faire un petit *bundle install* pour installer les éventuelles gems manquantes.

Première chose, on vérifie que l'URL entrée en argument a la bonne syntaxe.

``` ruby
def scrape_google(url)
  if url =~ /^#{URI::regexp}$/
```

On instancie ensuite la variable "indexed_pages" qui contiendra nos résultats.

``` ruby
    indexed_pages = nil
```

Puis on commence le traitement, dans un block *begin...rescue*, en fixant un Timeout à 20 secondes pour l'ouverture de la page. Via la gem *Nokogiri*, dont j'ai déjà parlé [ici](http://www.antoine-brisset.com/blog/ruby-scraping/), on va scraper tout ce qui est contenu dans le XPath correspondant au nombre de résultats affichés par Google, e.g *Environ ... résultats (... secondes)*

``` ruby
    begin
      Timeout.timeout(20) do
        data            = Nokogiri::HTML(open("http://www.google.fr/search?hl=fr&q=site%3A#{url}").read, "UTF-8")
        results         = data.at_xpath("//*[@id=\"resultStats\"]").text
```

Ensuite, on va rendre plus propre la chaine de caractères

* en supprimant le contenu des parenthèses indiquant le temps d'exécution de la requête (via la méthode gsub)
* en supprimant la sous-chaîne "résultats".

``` ruby
        proper_results  = results.downcase.gsub(/\(.*\)/, "").delete("résultats")
        indexed_pages   = "Nombre de pages indexées : #{proper_results}."
      end
```

En cas d'erreur, on stocke le type d'erreur.

``` ruby
    rescue => e
      indexed_pages = "Nombre de pages indexées : #{e}."
    end
```

Si l'URI entrée comme argument n'est pas valide, on renvoie ceci :

``` ruby
  else
    indexed_pages = "Nombre de pages indexées : #{url} n'est pas une URL valide."
  end
```

Dans tous les cas, on renvoie la variable "indexed_pages", qui sera utilisée comme objet du mail, comme nous allons le voir dans la suite de l'article.

``` ruby
  return indexed_pages
end
```

## Envoyer un mail avec le nombre de résultats

Maintenant que nous avons défini la méthode permettant de stocker le nombre de pages indexées, il faut créer la méthode permettant d'envoyer cette information par mail. La [gem *Mail*](https://github.com/mikel/mail)  va nous permettre de réaliser cela facilement.

Dans l'exemple ci-dessous, j'utilise le smtp de gmail pour l'envoi du mail. Mais si votre sendmail est bien configuré, vous pouvez opter pour celui-ci. Je vous renvoie à la [doc](https://github.com/mikel/mail#sending-an-email) pour plus d'explications.

On crée un objet un mail avec *Mail.new* auquel on passe en attributs le destinataire du mail, l'expéditeur, l'objet et, dans le corps du mail, on renvoie à l'objet issu de la méthode scrape_google définie précédemment. Enfin, pour envoyer le mail, on utilise "deliver".

``` ruby
def send_mail(string)
  mail = Mail.new(
    :to               => 'toto@gmail.fr',
    :from             => 'toto@ec2-amazon.com',
    :subject          => 'Résultat de ma tâche cron SEO',
    :body             => "#{string}",
  )
  mail.delivery_method :smtp,{
    :address          => 'smtp.gmail.com',
    :port             => '587',
    :user_name        => 'votre_user@gmail.com',
    :password         => 'votre_mot_de_passe',
    :authentification => ':plain',
  }
  mail.deliver
end

index = scrape_google("http://www.nomdusite.com")
send_mail(index)
```

## Créer la tâche cron

Dernière étape, la création de la tâche cron. Installez tout d'abord la gem [*Whenever*](https://github.com/javan/whenever) sur votre instance. Vous pouvez :

* l'ajouter dans votre Gemfile de cette façon (et exécuter en console un *bundle install*)

``` ruby
gem 'whenever', :require => false
```

* ou alors l'installer directement en ligne de commande via "gem install whenever".

Dans le dossier où vous avez créé votre script, créez un nouveau dossier /config et ajoutez-y le fichier **schedule.rb** dans lequel vous allez définir votre tâche cron. La syntaxe est simple : il suffit de choisir une fréquence puis de définir quelle commande exécuter.

Par exemple, pour exécuter chaque jour à 8h notre script d'envoi de mail, que l'on appelera index.rb, le fichier schedule.rb contiendra les lignes suivantes :

``` ruby
every :day, :at => '8:00 am' do
   command "cd ~/mon_dossier/;ruby index.rb"
end
```

Pour que cette entrée soit ajoutée au crontab, il suffit ensuite dans la console d'exécuter la commande *whenever --update-crontab* au niveau du répertoire dans lequel se trouve le script.

Et voilà, vous recevrez chaque jour par mail le nombre de pages indexées sur votre site !
