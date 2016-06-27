---
title: Calcul de similarité avec Ruby
title_seo: Détection du contenu dupliqué avec Ruby et le Cosinus de Salton
description: Découvrez comment calculer un score de proximité sémantique (cosinus de Salton) entre les pages de votre site, grâce à plusieurs gems Ruby bien pratiques !
date: 2015-10-11 15:41:43 +0200
hero_image: semantic.jpg
thumbnail:
category: "Sémantique"
excerpt: Les solutions logicielles ou saas permettant de détecter le contenu dupliqué sur un site web sont, soit un peu trop opaques, soit un peu trop onéreuses à mon goût. Je vous présente donc ici un script rudimentaire, permettant à la fois, de crawler un site web en aspirant son contenu page à page, et de calculer la similarité de chacune des pages entre elles, en utilisant le tf-idf et le cosinus de Salton.
author:
---

Le script est disponible sur [Github](https://github.com/ABrisset/dc_checker/). En bonus, vous y trouverez également une méthode permettant de calculer l'indice de Jaccard. Côté performance, il y a très certainement des choses à revoir, notamment au niveau des calculs, très coûteux, et des requêtes MySql, non optimisées. Néanmoins, pour un petit site web, il fera très bien l'affaire.

## Crawler un site web : la gem Anemone

Pour crawler un site et répertorier l'ensemble de ses pages, il existe une gem Ruby très pratique : [Anemone](https://github.com/chriskite/anemone). Je vous invite à jeter un coup d'oeil à la documentation, vous verrez que les possibilités qu'elle offre sont très nombreuses.
Ici, je crée simplement une nouvelle instance d'Anemone, en lui passant en paramètre mon URL de départ, et en lui donnant l'instruction de ne suivre qu'un "niveau" de redirection.

``` ruby
Anemone.crawl(root_url, :redirect_limit => 1) do |anemone|
  skipped_links = %r{%23.*|\#.*|.*\.(pdf|jpg|jpeg|png|gif)}
  anemone.skip_links_like(skipped_links)
  anemone.on_every_page do |page|
    # Catch absolute URL and print it from terminal
    absolute_url = URI.decode(page.url.to_s)
    puts absolute_url
```

Pour éviter de suivre des liens images ou des liens vers des ancres internes, j'utilise la méthode `skip_links_like`, en lui passant en paramètre l'expression régulière adaptée.

## Extraire le contenu d'une page : le framework Treat

S'il existe de très bons outils avec Python pour le traitement automatique du langage naturel (cf [NLKT](http://www.nltk.org/)), peu de librairies aussi abouties sont disponibles avec Ruby. Néanmoins, en fouillant un peu, je suis tombé sur [Treat](https://github.com/louismullie/treat/wiki/Manual), qui permet de parser un texte, de le découper en entités logiques (titre, section, paragraphe, phrases), de catégoriser les mots, etc. Bref, plutôt complet.

Revenons-en à notre script. Maintenant qu'on a récupéré notre page web avec Anemone, on va utiliser les méthodes disponibles dans la classe `Page` pour récupérer uniquement le contenu texte de la page. Retirons donc les commentaires, les balises script, noscript et style, supprimons toutes les balises, décodons les éventuelles entités HTML et modifions la casse (minuscule).

``` ruby
def get_content_of(page)
  page.doc
      .xpath('//comment()')
      .remove
  page.doc
      .at('body')
      .search('//script|//noscript|//style')
      .remove
  HTMLEntities.new.decode(page.doc
                              .to_html
                              .gsub(/<[^>]+>/, "\s")
                              .downcase)
end
```
Le contenu est maintenant normalisé. On va ensuite utiliser Treat pour isoler les mots de notre page. Découpons tout d'abord le contenu en tokens, puis débarrassons-nous des signes de ponctuation et des valeurs numériques via la méthode `words`. Le tout sera stocké dans un array.

``` ruby
def get_words_of_document
  @document.apply(:chunk, :segment, :tokenize)
  @document.tokens.each do |t|
    t.words.each do |w|
      @page_content << w.to_s
    end
  end
  @page_content.flatten
end
```

Pour rendre l'analyse plus pertinente, on élimine les stop words et on transforme les caractères accentués en caractères non-accentués (voir le détail des méthodes dans le dossier `/lib/`).

``` ruby
words = analyzer.get_words_of_document
words = analyzer.remove_stop_words_from(words, stop_words)
words = analyzer.remove_accents_from(words)
```

Il n'y a plus qu'à stocker le couple URL <-> contenu en base, dans la table `pages`.

## Calculer la proximité sémantique entre deux pages : la gem Similarity

Pour le calcul du cosinus de Salton, utilisons la gem [Similarity](https://github.com/bbcrd/Similarity). Au préalable, on aura pris soin de créer une table matrice en base de données avec :

URL A => URL A <br>
URL A => URL B <br>
URL A => URL C <br>
URL A => URL D <br>
URL B => URL A <br>
URL B => URL B <br>
etc.

La méthode [`product`](http://ruby-doc.org/core-1.9.3/Array.html#method-i-product) tombe à point nommé pour effectuer cette tâche.

[UPDATE] : j'ai limité le volume de couples de pages à comparer entre elles en éliminant les doublons Par exemple les couples A => B et B => A sont des doublons, de même que A => A ou B => B qui ne doivent pas être comparés entre eux.

``` ruby
## Fill similarity table
pages_a = $connection.query("SELECT absolute_url FROM pages")
                     .map{ |row| row['absolute_url'] }
pages_b = pages_a.dup

pages_a.product(pages_b)
       .map{ |arr| arr.sort }
       .uniq
       .delete_if{ |arr| arr[0] == arr[1] }
       .each do |line|
          url_a = line[0]
          url_b = line[1]
          $connection.query("INSERT INTO
            similarity(
              url_a,
              url_b
            )
            VALUES(
              '#{url_a}',
              '#{url_b}'
            )"
          )
        end
```
Etape finale : le calcul.

Pour former le corpus, on instancie un nouveau document pour chaque URL en base, qu'on ajoute à notre corpus. Pour identifier chaque document, mettons à jour la table `pages`. Cela nous permettra par la suite de disposer d'un identifiant unique permettant de connaître quelles sont les URL comparées entre elles.

``` ruby
## Compute salton cosine
corpus        = Corpus.new
array_of_docs = Array.new
pages         = $connection.query("SELECT absolute_url,content FROM pages")
pages.each do |row|
  absolute_url  = row['absolute_url']
  content       = row['content']
  document      = Document.new(:content => content)
  corpus        << document
  array_of_docs << document
  cosine_id = document.id
  $connection.query("UPDATE pages
                     SET cosine_id      = '#{cosine_id}'
                     WHERE absolute_url = '#{absolute_url}'")
end
```

Passons alors au calcul de la similarité. Chaque objet `document` ayant été au préalable stocké dans un array, il suffit de boucler sur chacun de ces objets et d'utiliser la méthode `similar_documents`. Grâce à la correspondance entre l'URL et l'identifiant du document, on peut mettre à jour la table `similarity` avec les valeurs du cosinus de salton pour chaque couple d'URL.

``` ruby
array_of_docs.each do |doc|
  corpus.similar_documents(doc).each do |d, similarity|
    doc_a = doc.id
    doc_b = d.id
    $connection.query("UPDATE similarity
                       SET salton_cosine = '#{similarity}'
                       WHERE url_a =
                        (
                          SELECT absolute_url
                          FROM pages
                          WHERE cosine_id = '#{doc_a}'
                        )
                       AND url_b =
                        (
                          SELECT absolute_url
                          FROM pages
                          WHERE cosine_id = '#{doc_b}'
                        )
                      ")
  end
end
```

Si vous souhaitez avoir le détail du script, tout est [ici](https://github.com/ABrisset/dc_checker/), vous n'avez qu'à cloner le repo.

``` console
$ ~/Workspace/ git clone https://github.com/ABrisset/dc_checker.git
```

## Mise en pratique

Lançons le script et analysons les données pour mon site www.antoine-brisset.com.

``` console
$ ~/Workspace/dc_checker/ ./checker.rb http://www.antoine-brisset.com abrisset
```

Voici quelques résultats significatifs :

|URL A------------------------------------|URL B---------|Salton ---|
|-----------------------------------------|--------------|----------|
|/blog/categories/scripts-seo/            |/blog         |0.530091
|/blog/categories/seo-on-site/            |/blog         |0.724747
<br />
Comme on peut le voir ci-dessus, mes pages catégories sont en concurrence directe avec la page racine du blog.
Si je veux que mes pages catégories aient une chance de se positionner, j'aurai donc tout intérêt à ajouter -- a minima -- un texte d'introduction pour chacune des pages catégories.

Nous pouvons également, à partir de ces données, s'amuser à catégoriser les différentes URL, de manière à analyser les typologies de page qui ont une similarité forte. Mettons à jour la table similarity.

``` mysql
ALTER TABLE similarity
ADD category VARCHAR(255)
```

``` mysql
UPDATE similarity
SET category = (CASE
                WHEN url_a REGEXP '^.*categories.*$' THEN 'Page catégorie'
                WHEN url_a = 'http://www.antoine-brisset.com/' THEN 'Page d\'accueil'
                WHEN url_a = 'http://www.antoine-brisset.com/blog/' THEN 'Page blog'
                ELSE 'Page article'
                END)
```

Hop, on calcule une moyenne du cosinus par typologie de page.

``` mysql
SELECT category,AVG(salton_cosine)
FROM similarity
GROUP BY category
```
Sans surprise, ce sont la page blog et les pages catégories qui ont l'indice de similiarité "moyen" le plus important. Logique, puisque la page blog reprend un extrait de chaque article, et que les pages catégories ne sont qu'une sélection des extraits d'articles déjà présents sur la page blog.

![salton](/images/posts/excel.png "salton")

Voilà un exemple assez simple et pragmatique de détection du contenu dupliqué sur un site. Qu'en pensez-vous ? Est-ce selon une méthode fiable ?
