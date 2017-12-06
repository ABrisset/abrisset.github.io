---
title: Désindexer une page CMS sous Magento
title_seo: "Magento : ajouter noindex sur une page CMS"
description: "Découvrez comment désindexer une page CMS Magento, sans mettre les mains dans le cambouis !"
date: 2015-10-06 18:47:42 +0200
hero_image: on-site.jpg
thumbnail:
category: "SEO On-site"
excerpt: Cet article tient davantage du mémo que du billet. Il me permettra, ainsi qu'à vous je l'espère, d'avoir sous la main un reminder sur la façon de désindexer une page CMS avec Magento, sans mettre les mains dans le cambouis.
author:
slug: /noindex-cms-magento
---

## La manipulation

Pour empêcher l'indexation d'une page CMS sous Magento, outre la possibilité de passer par le .htaccess et le X-Robots-Tag ou encore d'installer un plug-in, il existe une solution simple, accessible à quiconque possède un accès au back-office et rapide à mettre en oeuvre.

Rendez-vous dans **CMS > pages**, cliquez sur la page voulue, puis, une fois la page chargée, sur l'onglet **design**.
Dans le champ **XML de mise à jour d'agencement**, entrez ce bloc

``` xml
<reference name="head">
  <action method="setRobots">
    <value>noindex, follow</value>
  </action>
</reference>
```

## Pour quoi faire ?

Pourquoi utiliser ce bloc ? Tout simplement pour empêcher l'indexation de pages dupliquées, ou de pages que vous ne souhaitez pas voir apparaître dans les pages de résultats Google. Vous pouvez également, de même manière, utiliser ce bloc pour mettre à jour votre balise title.

``` xml
<reference name="head">
   <action method="setTitle">
    <value>Ma balise title</value>
  </action>
</reference>
```
Bien évidemment, on peut obtenir le même résultat en modifiant, directement, le nom de la page, mais je trouve que c'est plus propre et moins intrusif de passer par ce bloc de code.

Enfin, sachez qu'il est possible d'utiliser ce bloc à d'autres fins que le SEO, par exemple pour appeler un fichier CSS custom.

``` xml
<!--- Appel du fichier css custom.css situé dans le répertoire /skin/frontend/default/your_theme/css -->
<reference name="head">
  <action method="addItem">
     <type>skin_css</type>
     <name>custom.css</name>
  </action>
</reference>
```

A vous de jouer !
