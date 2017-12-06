---
title: Installer Serposcope sur un Raspberry Pi 2
title_seo: "Raspberry Pi 2 : installer un logiciel de suivi de positions"
description: "Vous avez un Raspberry Pi et la fibre SEO ? Apprenez à utiliser votre nano ordinateur comme un outil de suivi de vos positions sur Google !"
date: 2016-01-08 18:24:55 +0100
hero_image: tool.jpg
thumbnail:
category: "Outils SEO"
excerpt: "Ayant récemment fait l'acquisition d'un <a href='http://www.amazon.fr/Raspberry-Pi-Quad-Core-Starter/dp/B00T7KW3Y0/ref=sr_1_6?s=computers&ie=UTF8&qid=1452271852&sr=1-6&tag=antoine-brisset-21'>Raspberry Pi 2</a>, je commence petit à petit à en découvrir tout le potentiel, notamment en termes d'automatisation. S'agissant d'une machine tournant sous un OS dérivé de Debian, Raspbian, elle permet de faire tout un tas de choses amusantes, comme par exemple du suivi de positionnement avec <a href='https://serposcope.serphacker.com/fr/'>Serposcope</a>, un outil open source développé par Serphacker (au passage, merci à lui !). Je vous explique ici comment l'installer sur votre machine..."
author:
slug: /installer-serposcope-raspberry-pi-2
---

## Installer Java 8

Tout d'abord, commencez par télécharger l'environnement de développement Java JDK 8, requis pour faire fonctionner Serposcope correctement. Rendez-vous à [cette adresse](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) et téléchargez le fichier jdk-8u65-linux-arm32-vfp-hflt.tar.gz.

Copiez-le sur votre Raspberry Pi, dans un dossier `/serposcope/` par exemple (remplacez l'IP ci-dessous par celle de votre Raspberry) :

``` console
scp jdk-8u65-linux-arm32-vfp-hflt.tar.gz pi@192.168.0.12:Workspace/serposcope
```

Connectez-vous ensuite en SSH à votre Raspberry Pi :

``` console
ssh pi@192.168.0.12
```

Rendez-vous dans le dossier `/serposcope/` :

``` console
cd Workspace/serposcope/
```

Décompressez votre archive jdk et copiez-la vers le dossier `/opt/` (par exemple) :

``` console
sudo tar zxvf jdk-8u65-linux-arm32-vfp-hflt.gz -C /opt
```

Ouvrez enfin votre fichier .bashrc et modifiez la variable d'environnement `JAVA_HOME` de manière à définir la version de java à utiliser par défaut, c'est-à-dire la 1.8 :

``` console
nano ~/.bashrc
```

``` vim
export JAVA_HOME=/opt/jdk1.8.0_65
export PATH=$PATH:$JAVA_HOME/bin
```

Pour être sûr que tout est OK, vérifiez que votre version de java est bien la 1.8 :

``` console
java -version
```

## Installer Serposcope

Depuis votre Raspberry Pi, téléchargez le fichier .deb de Serposcope :

``` console
wget https://serposcope.serphacker.com/download/2.0.0/serposcope_2.0.0_all.deb
```

Installez-le :

``` console
sudo dpkg -i serposcope_2.0.0_all.deb
```

Editez ensuite le fichier de conf de Serposcope de façon à ce qu'il puisse localiser correctement `JAVA_HOME`. Celui-ci devrait se trouver dans `/etc/default/serposcope.conf` :

``` console
nano /etc/default/serposcope
```

``` vi
# specify alternative JAVA_HOME here
JAVA_HOME=/opt/jdk1.8.0_65
```

Démarrez Serposcope :

``` console
sudo service serposcope start
```

Vous n'avez plus qu'à utiliser un client comme [VNC Viewer](https://www.realvnc.com/download/viewer/) pour accéder à votre Raspberry en mode "graphique" puis à vous connecter à l'adresse http://127.0.0.1:7134. Entrez vos mots-clés, vos sites, créez une tâche Cron et laissez le Raspberry Pi faire le reste !


![Serposcope - Authentification](/images/posts/serposcope.png "Serposcope")

