# PASSATION À CLAUDE — Générateur de rapports de visite de chantier

## Mission
Reprendre le projet Flutter fourni, l'auditer, le terminer proprement et produire un APK Android installable et testé. Ne pas se limiter à expliquer comment faire : modifier réellement le code, compiler, corriger les erreurs et fournir les livrables.

## Contexte produit
Application mobile pour le **Département électromécanique – Générateur de rapports**. Android en priorité, architecture Flutter permettant une version iOS ultérieure.

### Décisions à respecter impérativement
- Application utilisable sans connexion pour les fonctions essentielles : ouvrir, créer/enregistrer une visite, consulter les anciennes visites, ajouter des participants, saisir les constats par lieu, prendre et associer des photos, générer/partager un PDF. La synchronisation éventuelle ne doit jamais être obligatoire.
- Palette verrouillée :
  - bleu pétrole `#164B57` (couleur principale)
  - turquoise clair `#D9EEF0`
  - jaune orangé `#F2A23A`
  - blanc / fonds très clairs
- Garder le motif du casque de chantier jaune/orangé. **Aucun symbole électrique**. Ne pas remplacer le bleu pétrole par du vert.
- Ne pas réinventer l'interface validée : accueil avec « Nouvelle visite », « Mes rapports », « Photos », « Dictée », « Divers ».
- Informations de visite : site, date, objet/suivi en texte libre.
- Participants illimités : nom et fonction.
- Lieux visités librement ajoutables (cour, salle, couloir, local technique, toiture, chaufferie, musée, gymnase, etc.).
- Pour chaque lieu : commentaire libre et photos associées à ce lieu précis.
- Le PDF cible est un A4 portrait intitulé **COMPTE RENDU DE VISITE DE CHANTIER**, avec en-tête cohérent sur toutes les pages, participants avec pictogrammes, constats par lieu, photos à côté/sous leur commentaire, points de vigilance, prochaines étapes/actions, synthèse et espaces de signatures/validation. Pagination propre et en-tête répété. Pas de vague ni de ligne jaune en bas de page.
- La dictée doit être réellement hors ligne uniquement si le moteur local du téléphone le permet. Ne jamais promettre qu'elle fonctionne partout sans Internet ; afficher clairement l'indisponibilité si le moteur hors ligne n'est pas présent.

## État réel du dépôt fourni (ne pas surestimer)
Le dépôt initial est une base de développement 0.3, pas une application finalisée.
- `lib/main.dart` : écran d'accueil, formulaire de visite, saisie participants/lieux, prise de photo par caméra, liste de rapports et premier export PDF.
- `lib/data_store.dart` : stockage SQLite local, participants et lieux encodés en JSON, copie des photos dans le répertoire privé de l'application.
- `pubspec.yaml` : dépendances Flutter, SQLite, image_picker, PDF, printing, intl, uuid.
- Les photos sont prévues dans le PDF, mais le rendu n'a pas été compilé ni testé.
- Les fonctions Photos, Dictée et Divers sont actuellement des tuiles informatives, pas des écrans fonctionnels.
- Il n'y a pas encore de modification/suppression de visite.
- Le PDF actuel est une première version technique, pas la maquette finale validée.
- La dictée n'est pas implémentée.
- Aucune compilation, aucun test sur appareil, aucun test en mode avion n'a été réalisé.
- Le dossier Android natif n'est pas encore présent dans ce dépôt minimal. Le créer avec Flutter.
- L'environnement initial n'avait ni Flutter, ni Dart, ni Android SDK : aucun APK n'a donc été produit.

## Tâches demandées — ordre de priorité

### 1. Audit et mise en état du projet
1. Examiner tous les fichiers et versions de dépendances.
2. Créer le projet Android natif manquant avec Flutter stable (`flutter create . --platforms=android --org fr.departement.electromecanique`, en adaptant proprement si nécessaire).
3. Vérifier le `applicationId`, le `minSdk`, les permissions caméra et les réglages Gradle/Java.
4. Exécuter `flutter pub get`, `dart format`, `flutter analyze` et les tests.
5. Corriger toutes les erreurs et avertissements importants. Ne pas ignorer les problèmes avec des suppressions arbitraires de règles lint.
6. Ajouter des tests automatisés pour le stockage et les transformations de données.

### 2. Fiabiliser les fonctions essentielles hors connexion
1. Garantir l'initialisation robuste de SQLite et la gestion des erreurs.
2. Ajouter les opérations consulter, modifier et supprimer une visite.
3. Éviter les pertes de photos lors d'une modification ; supprimer les fichiers photo orphelins lors d'une suppression seulement si aucun autre rapport ne les référence.
4. Vérifier la conservation des données après fermeture/redémarrage.
5. Tester en mode avion sur un appareil ou émulateur Android. Documenter exactement les tests réellement effectués.

### 3. Photos
- Prise de vue et, si possible, sélection depuis la galerie.
- Copie immédiate vers le stockage privé de l'application.
- Aperçu, suppression d'une photo et association au bon lieu.
- Gestion des refus de permission, annulation et fichiers manquants.
- Compression raisonnable pour éviter des PDF énormes.

### 4. PDF final
Reprendre la structure décrite dans les décisions produit. A4 portrait, mise en page soignée, couleurs de la charte, en-tête répété, participants en deux colonnes si possible, lieux et commentaires, photos associées à leurs constats, synthèse, vigilance, actions et signatures. Prévoir les textes longs, les nombreuses photos et les sauts de page. Le PDF doit pouvoir être prévisualisé, enregistré et partagé.
Ne pas inventer de logo institutionnel : prévoir un emplacement ou demander le fichier officiel si nécessaire.

### 5. Dictée
Étudier un plugin compatible Android/iOS. Tester explicitement le mode hors ligne sur appareil réel. Si la reconnaissance locale n'est pas disponible, garder la saisie clavier fonctionnelle et afficher une explication ; ne pas basculer silencieusement vers un service cloud.

### 6. Livraison
Fournir :
- le code source complet corrigé ;
- un APK `release` installable ;
- les instructions de compilation reproductibles ;
- le résultat de `flutter analyze` et des tests ;
- la liste des tests manuels réellement exécutés, notamment mode avion, photos, PDF et redémarrage ;
- les limites connues.

Ne pas prétendre que l'APK est testé si seule la compilation a réussi. Ne pas prétendre que le mode avion fonctionne sans essai concret.

## Commandes de validation attendues
```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
```
APK attendu :
`build/app/outputs/flutter-apk/app-release.apk`

## Compilation cloud (GitHub Actions)
Un workflow `.github/workflows/android-apk.yml` est fourni dans ce dépôt. Il doit créer le squelette Android si absent, analyser, tester puis compiler l'APK. Vérifier et adapter le workflow si les versions Flutter/Java/Gradle l'exigent. À la fin, publier l'APK comme artifact téléchargeable du workflow. Un dépôt GitHub est nécessaire pour déclencher cette compilation.

## Consignes de collaboration
- Avancer directement sans demander une validation pour chaque petite décision technique.
- Demander uniquement les éléments réellement indispensables (par exemple le logo officiel ou une maquette PDF de référence si elle n'est pas jointe).
- Conserver strictement la charte et les choix fonctionnels ci-dessus.
- Signaler les blocages et distinguer clairement : fait, compilé, testé, non testé.
- Ne pas remplacer les exigences hors ligne par une simple mise en cache d'une application qui dépend d'Internet.
