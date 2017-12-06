---
title: "Clustering de mots-clés : un exemple avec Gephi"
title_seo: "Cluster de mots-clés : utiliser le coefficient de Dice & Gephi"
description: "Découvrez comment utiliser Gephi pour cartographier un univers sémantique. Quelques lignes de code, un peu de tuning dans le logiciel et le tour est joué !"
date: 2016-09-27 18:50:00 +0200
hero_image: semantic.jpg
thumbnail:
category: Sémantique
excerpt: "La notion de clusterisation est à nouveau abordée sur le blog, mais sous un autre angle. J'ai en effet décidé d'explorer les fonctionnalités de Gephi pour générer la cartographie d'un univers sémantique. L'objectif est de visualiser à la fois l'intérêt d'un mot-clé (volume de recherche) et la façon dont il est connecté aux autres mots-clés (similarité sémantique)"
author:
slug: /clustering-gephi
---

[Dans le billet précédent](http://www.antoine-brisset.com/blog/clustering-ruby-k-means/), j'ai présenté une méthode s'appuyant sur l'algorithme K-Means pour partitionner un corpus de mots-clés. Bien que très simple d'accès, cette méthode présente l'inconvénient de devoir connaître à l'avance le nombre de clusters que l'on souhaite créer. Pas top.

J'ai donc poursuivi mes recherches : j'ai tout d'abord fait l'acquisition de l'ouvrage de Massih-Reza Amini et Éric Gaussuier, [Recherche d'information - Applications, modèles et algorithmes. Fouille de données, décisionnel et big data](https://www.amazon.fr/Recherche-dinformation-Applications-algorithmes-d%C3%A9cisionnel/dp/2212135327/?tag=antoine-brisset-21) qui consacre un chapitre très intéressant au partitionnemet de données, et en parallèle, je me suis intéressé de plus près à Gephi.
J'en ai ressorti une méthodologie concrète de visualisation d'un ensemble de mots-clés, qui s'appuie sur le *coefficient de Dice*, ainsi que sur Gephi et ses algorithmes de clustering embarqués.


## 1ère étape : récupérer les mots-clés et leur volume de recherche

La première étape va consister, bien entendu, à récupérer le maximum de mots-clés dans la thématique que vous souhaitez étudier. Pour cela, je ne rentre pas dans le détail, utilisez Keywords Planner, SemRush ou tout autre outil qui pourra vous donner une correspondance entre un mot-clé et un volume de recherche mensuel.

Formattez votre fichier de la façon suivante : une 1ère colonne intitulée "Id", une 2ème colonne intitulée "Label" et une dernière colonne intitulée "Weight".
Dans la première colonne figureront vos mots-clés, dans la deuxième colonne, vos mots-clés à nouveau (simple copier/coller) et dans la troisième colonne les volumes de recherche.
Enregistrez votre fichier au format CSV, sous le nom **nodes.csv**. Votre fichier "noeuds" est prêt à être importé dans Gephi. Nous y reviendrons tout à l'heure.


## 2ème étape : calculer la similarité entre chaque mot-clé
### Normaliser les mots-clés

Avant de passer au calcul de la similarité, nous allons d'abord procéder à un ensemble de pré-traitements, en Ruby, qui nous permettront de mieux regrouper nos mots-clés.
Reprenons le même jeu de données que dans l'article précédent, que nous allons stocker dans un tableau.

``` ruby
keywords = ["consultant seo","référencement naturel","expert seo","referencement naturel","consultant referencement","consultant référencement","agence de référencement","agence seo","consultant en référencement","expert referencement","agence référencement","consultant référencement naturel","agence referencement","consultant en referencement","agence de referencement","référencement seo","experts referencement","référenceur freelance","consultant référencement internet","expert référencement","consultant referencement naturel","consultant en référencement naturel","conseil seo","referenceur freelance","spécialiste référencement naturel","search engine optimization for dummies","seo referencement","consultant en referencement naturel","devis referencement","top seo company","expert référencement naturel"]
```

La première étape consiste à transformer chaque expression-clé en tokens.
Voici comme je procède : je découpe chaque chaîne de caractères dès que je trouve un espace.

``` ruby
def get_tokens_from(string)
  tokens = string.split(' ')
  tokens
end
```

Une fois la tokenisation effectuée, je vais chercher dans une base de données de lemmes (voir mon article [sur l'analyse sémantique](http://www.antoine-brisset.com/blog/seo-campus-lille-2016/)), la correspondance entre chaque token et son lemme.
J'utilise également le framework Treat pour déterminer la catégorie morpho-syntaxique de chaque mot et ainsi lever l'ambiguïté lorsque plusieurs lemmes sont possibles pour un même token.

La méthode ci-dessous retrouve en base de données, pour chaque token, le lemme qui lui est associé, puis stocke le tout dans un tableau et élimine les accents et les stop words (deux fonctions très simples sont utilisées pour ces opérations, `remove_accents_from` et `delete_stop_words_from`, que je ne détaillerai pas ici).

``` ruby
def get_lemmatised_words_from(tokens)
  keywords = Array.new(0)
  tokens.each do |w|
    begin
      word_str = $client.escape(w)
      rows     = $client.query("SELECT lemma,word,category
                                FROM lemmas
                                WHERE word   = '#{word_str}' COLLATE utf8_bin
                                AND category = '#{w.category}'
                                LIMIT 1")
      if rows.size > 0
        keywords << remove_accents_from(rows.map{ |row| row["lemma"] }.first)
      else
        keywords << remove_accents_from(word_str)
      end
    rescue => e
      puts "#{w} => #{e}"
      next
    end
  end
  delete_stop_words_from(keywords)
end
```

### Calculer le coefficient de Dice

On peut maintenant passer à la première étape du partitionnement. Comme expliqué [dans le livre de
Massih-Reza Amini et Éric Gaussuier](https://www.amazon.fr/Recherche-dinformation-Applications-algorithmes-d%C3%A9cisionnel/dp/2212135327/?tag=antoine-brisset-21), lors de tout travail de partitionnement, la 1ère étape consiste à choisir "une mesure de similarité" entre les documents.
Plusieurs mesures de similarité sont présentées dans ce livre, et notamment le *coefficient de Dice*, que j'ai retenu pour mon analyse. Il est assez proche de l'**indice de Jaccard** et se calcule en divisant le double l'intersection de deux ensembles, par l'union de ces deux ensembles.

La méthode ci-dessous passe en revue chaque mot-clé, calcule leur similarité un à un via le coeficient de Dice, puis stocke les résultats dans un tableau.

``` ruby
def get_results_from(data)
  results = Array.new(0)
  data.each do |k, v|
    data.dup.each do |kb, vb|
      dice = 2 * (v & vb).count.to_f / (v.count + vb.count)
      dice = dice.round(2)
      results << [k, kb, dice]
    end
  end
  results
end
```

Il ne reste plus qu'à créer le fichier **edges.csv**, qui indiquera à Gephi le degré "d'attirance" entre chaque noeud.

``` ruby
def make_edges_csv_file_from(array)
  CSV.open("./edges.csv", "wb", {:col_sep => ";"}) do |csv|
    csv << ["source", "target", "weight"]
    array.each do |row|
      csv << [row[0], row[1], row[2]]
    end
  end
end
```

Et voilà, nous avons maintenant toutes les données nécessaires, passons à l'utilisation de Gephi !
Pour ceux que ça intéresse, le code complet est ici : [https://gist.github.com/ABrisset/661a87fb11a16807cf4ae984e7df8c13](https://gist.github.com/ABrisset/661a87fb11a16807cf4ae984e7df8c13).


## 3ème étape : visualiser les données dans Gephi
### Importer les données

Ouvrez Gephi, cliquez sur "Fichier > Nouveau Projet", puis rendez-vous dans "Laboratoire de données", et cliquez sur "Importer feuille de calcul".


Allez rechercher votre fichier **edges.csv**. C'est lui qui indiquera à Gephi quel est le degré d'attirance entre chaque paire de mots. Sélectionnez "En tant que table des liens", choisissez le bon séparateur, puis cliquez sur suivant. Dans la fenêtre suivante, cochez "Créer les noeuds manquants", puis cliquez sur "Terminer".

![Edges - Gephi](/images/posts/edges.png "Liens")

Ensuite, répétez la même opération, mais cette fois pour les noeuds. Il faut sélectionner "En tant que table des noeuds", puis à la fenêtre suivante, renseigner "Integer" en tant que type de données pour le champ "Weight" et veiller à bien décocher "Forcer les noeuds importés à être de nouveaux noeuds".

Grâce à la colonne "Id" de votre fichier noeuds, Gephi est en mesure d'identifier quels sont les noeuds dans les liaisons "Source" et "Target".

![Nodes - Gephi](/images/posts/nodes_1.png "Noeuds - étape 1")

![Nodes (2) - Gephi](/images/posts/nodes_2.png "Noeuds - étape 2")

### Jouer avec les paramètres de Gephi

La dernière étape consiste à customiser les noeuds et les liens en fonction de notre objectif de clusterisation. Rendez-vous dans "Vue d'ensemble".

Tout d'abord, lancez l'algorithme "Modularity" via le panel de droite. Celui-ci permet d'identifier des communautés dans une structure de graphes. Plus d'infos [ici](https://github.com/gephi/gephi/wiki/Modularity).
Ensuite, dans le panel de gauche, cliquez sur "Partition" puis "Noeuds" et choisissez "Modularity Class". Trois clusters différents ont été trouvés : les noeuds se colorent en fonction de leur "communauté" de rattachement.

![Modularity - Gephi](/images/posts/modularity.png "Modularity")

Basculez sur l'onglet "Classement", choisissez "Noeuds" et dans "Taille/Poids", sélectionnez "Weight" : les noeuds sont désormais de taille proportionnelle au volume de recherche. Vous pouvez procéder de la même façon pour la taille des labels.

![Weight - Gephi](/images/posts/weight.png "Weight")

Il ne reste plus qu'à ajouter un peu de spatialisation. Pour cela, utilisons Force Atlas 2, avec les paramètres ci-dessous.

![Force Atlas - Gephi](/images/posts/spatialisation.png "Force Atlas")

### Exporter la visualisation

Laissons Force Atlas tourner quelques instants. Direction maintenant l'onglet "Visualisation". Vous devriez obtenir la visualisation ci-dessous, avec 3 clusters :

* mots-clés autour de "référencement" + "site"
* mots-clés autour de "seo"
* mots-clés autour de "référencement" + "agence", "naturel", etc.

Un conseil : ouvrez l'image dans un nouvel onglet et téléchargez l'extension Chrome SVG Navigator pour zoomer ;)

![SEO visualisation](/images/posts/seo.svg "Visualisation des clusters")

Que pensez-vous de cette visualisation ? Pour ma part, je trouve que c'est un bon moyen de dégrossir une thématique et d'identifier rapidement les chantiers SEO prioritaires, c'est-à-dire les territoires sémantiques sur lesquels concentrer ses efforts.

Je pense, néanmoins, que l'on pourrait obtenir une meilleure granularité en comparant les n-grammes entre eux, et non uniquement les mots. À suivre ;)
