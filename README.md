# Meine Gerichte

Eine Flutter-App zum lokalen Verwalten von Gerichten. Gerichte lassen sich mit Name, Beschreibung und Preis anlegen, anzeigen, bearbeiten und löschen. Die Daten bleiben in einer SQLite-Datenbank auf dem Gerät gespeichert.

## Starten

Flutter mit Dart 3.11.1 oder neuer installieren und dann ausführen:

```sh
flutter pub get
flutter run
```

Mit `flutter analyze` und `flutter test` lässt sich das Projekt prüfen.

## Aufbau

- `lib/model`: Datenmodell für Gerichte
- `lib/database`: lokale SQLite-Datenbank und CRUD-Operationen
- `lib/screens`: Liste, Formular und Löschbestätigung
- `lib/app.dart`: Material-3-Theme mit orangefarbenem Akzent

Die Oberfläche orientiert sich an [E-Commerce](https://github.com/jonasermert/E-Commerce). Sie benötigt weder Konto noch Server. Unterstützte Flutter-Projektplattformen sind Android und iOS. Eine Lizenz wurde bisher nicht festgelegt.
