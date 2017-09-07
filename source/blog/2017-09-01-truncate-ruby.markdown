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

L'objectif est de tronquer un contenu texte, sans couper un mot en plein milieu. Car oui, on pourrait tronquer à partir de x caractères, sans se soucier de l'endroit où ça tombe, mais ce serait beaucoup moins élégant...

Notre méthode reçoit 2 arguments : une chaine de caractères, ici la variable `text`, et une longueur définie, ici 160 caractères.

``` ruby
def truncate(text, length = 160)
  words = text.split
  susp  = "..."
  result = words.inject([]) do |memo, word|
    if (memo + [word]).join(" ").length < length
      memo << word
    else
      memo
    end
  end
  if result.last =~ /[[:punct:]]/
    result.pop
    result.join(" ").concat(susp)
  else
    result.join(" ").concat(susp)
  end
end
```

La 1ère opération consiste à éclater notre chaine de caractères et à stocker chaque sous-chaine dans un tableau, ici `words`.

Nous bouclons sur `words`, en utilisant la méthode `inject`. Similaire à `reduce`, cette méthode permet, lorsqu'un lui passe un bloc en paramètre, d'incrémenter un "mémo" à chaque itération. Le mémo est ici sous la forme d'un tableau vide ([]). Tant que la longueur du mémo + la longueur du mot (espace compris) est inférieure au nombre de caractères choisi (160 caractères par défaut), on stocke dans notre mémo la valeur de `word`. Si la longueur du mémo est supérieure à 160 caractères, on arrête d'incrémenter le mémo.

Pour améliorer l'expérience utilisateur (cf commentaire de Xavier), on ajoute des points de suspension à notre chaine de caractères. Pour cela, on vérifie d'abord que le dernier élément du tableau correspond à un signe de ponctuation. Si c'est le cas, on supprime cet élément via la méthode `pop`. Puis on reforme une chaine de caractères complète à l'aide de `join`. La méthode `join` permet de convertir chaque élément d'un tableau en chaines de caractères, séparées par le caractère de notre choix, ici un espace. Enfin, on concatène les points de suspension à la chaine de caractères retournée, via la méthode `concat`.

Et voilà, vous disposez maintenant d'un helper pour tronquer vos contenus et éviter le duplicate content interne !
