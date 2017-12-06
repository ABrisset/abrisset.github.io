---
title: "Comment Effectuer Une Redirection Nginx ?"
title_seo: "Redirections Nginx (301)"
description: "Vous débutez sur Nginx ? Voici un panorama des principales directives à mettre en place pour effectuer vos redirections serveur."
date: 2013-03-21
hero_image: server.jpg
category: "Administration Serveur"
excerpt: "Dans le petit monde des serveurs HTTP, Nginx est encore peu répandu, en comparaison de son cousin Apache. Néanmoins, cette techno d'origine russe est très intéressante d'un point de vue performances. Les plus gros sites l'ont d'ailleurs adopté : GitHub et Wordpress tournent ainsi sous 'engine-X'..."
slug: /redirect-ngnix
---

Dans ce 1er article, il ne sera pas question de perf' mais de redirections. Rediriger correctement les pages de son site est en effet vital aussi bien d'un point de vue SEO que d'un point de vue UX, par exemple en situation de refonte.

La grande différence avec Apache, c'est qu'avec Nginx vous n'avez pas accès à un fichier de type .htaccess. Toutes les directives doivent être directement implémentées au niveau du fichier de configuration serveur, auquel vous pouvez avoir accès en règle générale via ce chemin *_etc/nginx/nginx.conf*. Si vous avez créé plusieurs virtual hosts, en revanche, les modifications seront à effectuer ici *_/etc/nginx/sites-available/votre-domaine.com*. A noter que l'équivalent Nginx de mod_rewrite (Apache) est HTTP rewrite module.

Passons maintenant à la pratique.

## Redirection basique : page à page

Pour effectuer une redirection d'une page vers une autre, voici comment il faut procéder dans la conf' Nginx.

``` nginx
server {
  listen 80;
  server_name www.votre-domaine.com;
  rewrite  ^/votre-page.html$  http://www.votre-domaine.com/nouvelle-page.html permanent;
}
```

A noter que si vous utilisez le flag "permanent", la redirection sera de type 301, alors que si vous utilisez "redirect", celle-ci sera de type 302 (temporaire).

## Redirection d'un set d'URLs

Bien entendu, il est possible de faire usage des expressions régulières, par exemple pour rediriger tout un groupe d'URLs partageant une syntaxe commune.

``` nginx
rewrite ^/dossier/pages-id-.*.html$ http://www.votre-domaine.com/nouveau-dossier/pages-$1.html permanent;
```

## Redirection d'une URL avec paramètres vers une URL sans paramètres

Dans le cas d'une URL avec paramètres, que vous souhaiteriez rediriger vers une nouvelle URL débarrassée de ces paramètres, voici la bonne manière de faire. Ici, le paramètre est par exemple ?page.

``` nginx
location ~ /ancienne-page.php {
  if ($args ~ page=100){
    rewrite ^ http://www.votre-domaine.com/nouvelle-page.html? permanent;
  }
}
```

C'est le point d'interrogation qui donne l'instruction à Nginx de ne pas ajouter les éventuels paramètres derrière l'URL. "args" permet de définir les paramètres à matcher. Location permet de définir le pattern d'URLs concernés par le rewrite. Le tilde introduit une regexp (case sensitive).

## Redirection d'une URL si un paramètre existe

Si vous voulez rediriger tout un set d'URLs contenant un paramètre, peu importe la valeur, vers une URL sans paramètre voici la syntaxe à adopter avec ici un paramètre ?page par exemple

``` nginx
location ~ /ancienne-page.php {
  if ($arg_page != ""){
    rewrite ^ http://www.votre-domaine.com/nouvelle-page.html? permanent;
  }
}
```

Si vous voulez faire la même chose mais en conservant les paramètres dans l'URL de destination, voici comment procéder. Dans l'exemple ci-dessous, on redirige les urls contenant le paramètre page vers une url où la valeur de ce paramètre est passée dans le slug.

``` nginx
location ~ /ancienne-page.php {
  if ($arg_page != ""){
    rewrite ^ http://www.votre-domaine.com/nouvelle-page/$arg_page? permanent;
  }
}
```

## Redirection vers le sous-domaine www

Si vous souhaitez que toutes les requêtes sur votre-domaine.com soient redirigées vers www.votre_domaine.com, voici le code à utiliser.

``` nginx
server {
  listen 80;
  server_name votre-domaine.com;
  rewrite ^/(.*) http://www.votre_domaine.com/$1 permanent;
}
```

## Redirection ou code serveur spécifique en fonction du user-agent

Vous pouvez également avoir besoin d'effectuer une action spécifique en fonction du user agent qui se présente. Par exemple, envoyer un forbidden sur une page que Googlebot ou Bingbot ne doivent pas crawler, comme une page de login wordpress.

``` nginx
location ~ (wp-admin|wp-login\.php) {
  if ($http_user_agent ~* "(bingbot|googlebot)") {
    return 403;
    break;
  }
}
```

Ici on target les pages wp-login.php et wp-admin. On vérifie si l'user-agent demandant la page est Googlebot ou Bingbot. Si c'est le cas, on envoie un code d'erreur 403. L'utilisation du tilde + étoile permet de rendre la regexp case insensitive.
Attention ! L'utilisation de "break" indique que le serveur ne doit appliquer les directives qu'à l'intérieur du bloc défini par "location". A l'inverse avec "last", le serveur recherche une URI qui pourrait matcher avec le pattern dans tous les blocs "location" et applique le process défini s'il en trouve une.

## Bonus : définir une page à renvoyer en fonction d'un code serveur

Avec Nginx, vous pouvez  également définir quelle url doit être appelée en fonction d'un header http spécifique. Voici un exemple avec le code d'erreur 404.

``` nginx
error_page 404 /404.html;
```

Voilà donc quelques exemples de syntaxes à connaître pour gérer vos redirections. J'aborderai la question de la perf dans un autre article ;)
