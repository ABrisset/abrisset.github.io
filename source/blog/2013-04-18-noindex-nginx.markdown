---
title: "Ajouter un X-Robots-Tag avec Nginx"
title_seo: "Ajouter un X-Robots-Tag avec Nginx"
description: "Vous souhaitez empêcher Google d'indexer certaines pages ? Votre serveur est Nginx ? Testez la méthode du X-Robots-Tag..."
date: 2013-04-18
hero_image: server.jpg
thumbnail:
category: "Administration Serveur"
excerpt: "Un article très court pour une fois. Pour ceux qui passent de Apache à Nginx et qui souhaiteraient savoir comment ajouter un X-Robots-Tag dans le header http, voici quelle est la manière de procéder."
author:
---

Choisissez la(les) page(s) sur laquelle ajouter le champ, puis spécifiez les directives demandées. Ce qui donne :

``` nginx
location = /ma_page {
 add_header X-Robots-Tag "noindex, nofollow";     
}
```

Bien entendu, vous pouvez définir des règles custom en fonction du user-agent. Par exemple, si vous ne voulez envoyer un noindex qu'à Googlebot, il faudra écrire dans votre fichier de configuration :

``` nginx
location = /ma_page {
 if ($http_user_agent ~* googlebot) {
  add_header X-Robots-Tag "noindex, nofollow";
 }
}
```

A noter que le ~* indique que vous souhaitez que le matching soit non sensible à la casse.

Et voilà !
