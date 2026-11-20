# Générateur de rapports — version de développement 0.3

## Avancement de cette version
- Les photos prises depuis l'application sont copiées dans le répertoire privé de l'application pour éviter de dépendre du chemin temporaire fourni par la galerie/appareil photo.
- Le premier générateur PDF inclut maintenant les images associées aux constats, et non uniquement leur nombre.
- La base conserve les informations de visite, participants, lieux, commentaires et chemins des photos localement dans SQLite.

## Charte
- Bleu pétrole : `#164B57`
- Turquoise clair : `#D9EEF0`
- Jaune orangé : `#F2A23A`
- Fond blanc / très clair

## Important — état non certifié
Ce dépôt est un projet source Flutter en cours. Il n'a pas été compilé ni testé sur un appareil Android dans cet environnement. Le PDF est une première intégration des photos et doit encore être rapproché précisément du modèle A4 validé (en-tête institutionnel officiel, disposition exacte des blocs, signatures, pagination et finitions). La dictée hors connexion reste à développer et à tester selon les moteurs de reconnaissance disponibles sur Android/iOS. La garantie de fonctionnement complet hors connexion nécessite encore des essais en mode avion sur appareils réels.

## Compilation sur un poste équipé
Avec Flutter stable et Android SDK installés :
1. `flutter create . --platforms=android,ios`
2. `flutter pub get`
3. `flutter analyze`
4. `flutter run`
5. `flutter build apk --release`

iOS sera compilé ensuite sur macOS avec Xcode.


## Passation et compilation cloud
Le fichier `CLAUDE_HANDOFF.md` contient le cahier des charges de reprise, l'état réel du code et les critères de livraison. Il est destiné à être transmis avec tout le dossier à Claude.

Le workflow `.github/workflows/android-apk.yml` prépare le squelette Android s'il manque, lance formatage/analyse/tests puis construit l'APK. Pour l'utiliser, pousser ce dossier dans un dépôt GitHub et lancer l'action **Build Android APK**. Le fichier APK sera disponible dans les artefacts de l'exécution si toutes les étapes réussissent.

Attention : ce workflow n'a pas encore été exécuté dans ce dépôt. Il constitue une préparation de compilation, pas une preuve de compilation réussie.
