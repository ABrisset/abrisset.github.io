---
title: Tronquer un contenu avec Ruby
title_seo: "Couper une chaîne de caractères avec Ruby (truncate)"
description: "Vous avez besoin de tronquer une chaine de caractères sans couper un mot en plein milieu ? Voici une méthode qui va vous faire gagner du temps"
date: 2017-09-01 18:26:00 +0200
hero_image: code.jpeg
thumbnail:
category: "Scripts SEO"
excerpt: "Tronquer un contenu textuel est un besoin récurrent, que ce soit sur un blog ou sur un site e-commerce : extrait d'un article, description courte d'un produit, etc. Souvent, cette manipulation est nécessaire pour éviter le contenu dupliqué. Je vous propose ici un petit helper qui vous fera gagner du temps si le site est développé avec Ruby."
---

À noter que Ruby on Rails propose un helper pour cette opération, mais tous les projets Ruby ne sont pas forcément codés avec RoR :)

L'objectif est de tronquer un contenu texte, sans couper un mot en plein milieu. Car oui, on pourrait tronquer à partir de x caractères, mais ce serait beaucoup moins élégant...

Notre méthode reçoit 2 arguments : une chaine de caractères, ici la variable `text`, et une longueur définie, ici 160 mots.

La 1ère opération consiste à éclater notre chaine de caractères, et à stocker chaque sous-chaine dans un array, ici `words`.
Nous bouclons sur `words`, en utilisant la méthode `inject`. Similaire à `reduce`, cette méthode permet, lorsqu'un lui passe un bloc en paramètre, d'incrémenter un "mémo" à chaque itération. Le mémo sera ici sous la forme d'un array (vide, donc). Tant que la longueur du mémo est inférieure au nombre de mots choisis (160 mots par défaut), notre mémo s'incrémente. Lorsqu'il compte 160 mots, l'itération s'arrête. La dernière opération consiste à reformer une chaine de caractères à partir du tableau obtenu, à l'aide de `join`. La méthode `join` permet de convertir chaque élément d'un array en string, séparées par le caractère de notre choix, ici un espace.

``` ruby
def truncate(text, length=160)
  words = text.split()
  words.inject([]) do |memo,w|
    memo << w if memo.join.length < length
  end.join(" ")
end
```

Et voilà, vous disposez maintenant d'un helper pour tronquer vos contenus et éviter le duplicate content interne !
