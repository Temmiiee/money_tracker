# Money Tracker

Une application mobile simple et intuitive pour suivre vos finances, ventes, achats et inventaire.

## Fonctionnalités

### 🏠 Accueil (tableau de bord simplifié)
- Argent gagné ce mois
- Argent dépensé ce mois
- Ce qu'il reste en poche (gain - dépense)
- Indicateurs visuels selon la situation financière

### 💸 Je vends quelque chose
- Enregistrement des ventes avec nom et prix
- Gestion des ventes multiples
- Mise à jour automatique du stock

### 🛒 J'ai acheté quelque chose
- Enregistrement des achats
- Option pour indiquer si c'est pour refaire du stock
- Gestion des quantités

### 📦 Mon stock
- Visualisation des articles avec quantité restante
- Ajout de nouveaux produits
- Alerte pour les produits presque épuisés

### 📅 Mon mois
- Résumé mensuel clair
- Liste des transactions du mois
- Bilan financier (Revenus - Dépenses)

## Public cible

- Personnes qui ont des difficultés à gérer leurs dépenses
- Personnes ayant des difficultés en mathématiques
- Petits commerces cherchant une méthode simple pour enregistrer leurs ventes

## Caractéristiques

- Interface utilisateur simple et intuitive
- Langage clair, sans jargon technique
- Navigation facile (2-3 clics maximum)
- Design épuré avec des couleurs douces et des icônes explicites

## Installation

1. Assurez-vous d'avoir Flutter installé sur votre machine
2. Clonez ce dépôt
3. Exécutez `flutter pub get` pour installer les dépendances
4. Lancez l'application avec `flutter run`

## Publication sur le Google Play Store

Voici les étapes à suivre pour publier l'application sur le Google Play Store :

### 1. Préparer l'application

1. Mettez à jour la version de l'application dans `pubspec.yaml` si nécessaire
2. Retirez la ligne `publish_to: 'none'` du fichier `pubspec.yaml`
3. Assurez-vous que tous les tests passent et que l'application fonctionne correctement

### 2. Générer le fichier APK signé

```bash
# Générer une clé de signature (à faire une seule fois)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Créer le fichier key.properties à la racine du projet
# Contenu du fichier key.properties :
# storePassword=<mot de passe du keystore>
# keyPassword=<mot de passe de la clé>
# keyAlias=upload
# storeFile=<chemin vers le fichier keystore>

# Générer l'APK signé
flutter build apk --release
```

### 3. Créer un compte développeur Google Play

1. Visitez la [Console Google Play Developer](https://play.google.com/console/signup)
2. Payez les frais d'inscription (25$ USD, paiement unique)
3. Complétez votre profil développeur

### 4. Préparer les ressources pour la fiche Google Play

1. Créez des captures d'écran de l'application (au moins 2)
   - Téléphone : 16:9 (1920x1080 pixels minimum)
   - Tablette : 16:10 (1920x1200 pixels minimum)
2. Créez une icône haute résolution (512x512 pixels)
3. Créez une image d'en-tête (1024x500 pixels)
4. Préparez une description courte (80 caractères max) et une description complète
5. Définissez la catégorie de l'application (Finance)
6. Préparez une politique de confidentialité (obligatoire)

### 5. Soumettre l'application

1. Connectez-vous à la [Console Google Play Developer](https://play.google.com/console)
2. Créez une nouvelle application
3. Remplissez tous les détails requis
4. Téléchargez l'APK signé
5. Complétez le questionnaire de classification du contenu
6. Définissez le prix et la distribution (pays où l'application sera disponible)
7. Publiez l'application (elle sera d'abord en revue avant d'être disponible)

## Compilation pour la production

### Android
```
flutter build apk --release
```

### iOS
```
flutter build ios --release
```

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.# MoneyTracker
