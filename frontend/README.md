# AgriAdvisor - Frontend (Flutter)

Ce dossier contient une application Flutter minimale pour interagir avec le backend AgriAdvisor.

Installation et exécution:

```bash
cd frontend
flutter pub get
flutter run
```

Avant d'exécuter, vérifier `lib/services/api_service.dart` et ajuster `baseUrl` si nécessaire (ex: http://10.0.2.2:3000 pour émulateur Android, ou http://localhost:3000 pour certains environnements).

Fonctionnalités:
- Authentification (login/register)
- Formulaire d'analyse des conditions
- Résultats avec score, statut, variétés et fournisseurs

Note: UI minimale fournie; étendre selon besoin.
