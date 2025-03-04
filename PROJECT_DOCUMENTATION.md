# ZettlrIOS - Projektdokumentation

## Inhaltsverzeichnis
1. [Projektübersicht](#1-projektübersicht)
2. [Technische Architektur](#2-technische-architektur)
3. [Komponenten](#3-komponenten)
4. [Entwicklungsrichtlinien](#4-entwicklungsrichtlinien)
5. [Setup & Installation](#5-setup--installation)
6. [Bekannte Probleme](#6-bekannte-probleme)
7. [Roadmap](#7-roadmap)

## 1. Projektübersicht

### 1.1 Beschreibung
ZettlrIOS ist eine iOS-Anwendung für das Zettelkasten-System, die es Benutzern ermöglicht, Notizen in Markdown zu erstellen, zu verwalten und zu verknüpfen. Die App bietet CloudKit-Integration für Synchronisation und unterstützt verknüpfte Notizen im Zettelkasten-Stil.

### 1.2 Hauptfunktionen
- Markdown-basierte Notizen
- Zettelkasten-Verlinkungssystem
- Tag-Management
- CloudKit-Synchronisation
- Graph-Visualisierung
- Volltextsuche
- Export-Funktionen

### 1.3 Technologie-Stack
- Swift 5.9+
- SwiftUI
- CloudKit
- Core Data (geplant)
- Externe Bibliotheken:
  - Down (Markdown-Parsing)
  - SwiftyJSON
  - Yams (YAML-Verarbeitung)

## 2. Technische Architektur

### 2.1 Projektstruktur

├── App/ # App-Einstiegspunkt
├── Cloud/ # CloudKit-Integration
├── Export/ # Export-Funktionalität
├── Markdown/ # Markdown-Verarbeitung
├── Models/ # Datenmodelle
│ ├── Note.swift
│ └── SearchResult.swift
├── Storage/ # Datenpersistenz
├── Support/ # Hilfsfunktionen
├── Utils/ # Utility-Klassen
└── Views/ # UI-Komponenten
### 2.2 Architekturmuster
- MVVM (Model-View-ViewModel)
- Dependency Injection
- Repository Pattern für Datenzugriff
- Observer Pattern für UI-Updates

## 3. Komponenten

### 3.1 Datenmodell
```swift
struct Note: Identifiable {
    let id: UUID
    var title: String
    var content: String
    var tags: [String]
    var metadata: [String: String]
    var createdAt: Date
    var modifiedAt: Date
}
```

### 3.2 Hauptkomponenten
- **ZettelkastenStore**: Zentraler Datenspeicher
- **SyncCoordinator**: CloudKit-Synchronisation
- **LinkManager**: Verwaltung von Notiz-Verlinkungen
- **TagManager**: Tag-Verwaltung
- **SearchManager**: Suchfunktionalität

## 4. Entwicklungsrichtlinien

### 4.1 Code-Stil
- SwiftLint-Konfiguration befolgen
- Dokumentation für öffentliche APIs
- Async/await für asynchrone Operationen
- Vermeidung von Force-Unwrapping

### 4.2 Git-Workflow
1. Feature-Branches von `develop` erstellen
2. Pull Requests für Code-Review
3. Squash-Merge in `develop`
4. Release-Branches für Produktionsversionen

### 4.3 Testing
- Unit-Tests für Business Logic
- UI-Tests für kritische Benutzerflows
- Integration-Tests für CloudKit-Sync

## 5. Setup & Installation

### 5.1 Voraussetzungen
- Xcode 15.0+
- iOS 15.0+
- Apple Developer Account
- CloudKit-Container-Konfiguration

### 5.2 Entwicklungssetup
1. Repository klonen
2. Dependencies installieren
3. CloudKit-Container einrichten
4. Bundle-ID konfigurieren
5. Entwicklerzertifikate einrichten

### 5.3 Build-Konfiguration
```yaml
options:
  bundleIdPrefix: com.svencm.zettlr
targets:
  ZettlrIOS:
    platform: iOS
    type: application
    sources: [ZettlrIOS]
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.svencm.zettlr.ios
```

## 6. Bekannte Probleme

### 6.1 Kritische Probleme
1. **CloudKit-Konfiguration**
   - Falscher Container-Identifier
   - Fehlende Berechtigungen

2. **Performance**
   - Graph-Visualisierung bei vielen Nodes
   - Speichernutzung bei großen Datensätzen

3. **iOS-Kompatibilität**
   - Bundle-ID-Konfiguration
   - Fehlende Privacy-Beschreibungen

### 6.2 Erforderliche Fixes
```swift
// CloudKit-Container-ID korrigieren
let container = CKContainer(identifier: "iCloud.com.svencm.zettlr")

// Info.plist Ergänzungen
NSUbiquitousContainers
NSFaceIDUsageDescription
```

## 7. Roadmap

### 7.1 Kurzfristig (v1.1)
- [ ] CloudKit-Konfiguration korrigieren
- [ ] Performance-Optimierungen
- [ ] Grundlegende Tests implementieren
- [ ] Privacy-Beschreibungen hinzufügen

### 7.2 Mittelfristig (v1.2)
- [ ] Offline-Modus verbessern
- [ ] Core Data Integration
- [ ] Erweiterte Suchfunktionen
- [ ] Verbesserte Graph-Visualisierung

### 7.3 Langfristig (v2.0)
- [ ] Collaboration-Features
- [ ] Verschlüsselung
- [ ] Plugin-System
- [ ] Desktop-Sync

## 8. Support & Kontakt

### 8.1 Ressourcen
- GitHub Repository: [Link]
- Dokumentation: [Link]
- Issue Tracker: [Link]

### 8.2 Kontakt
- Entwickler: [Name]
- E-Mail: [E-Mail]
- Twitter: [@handle]

---

*Letzte Aktualisierung: [Datum]*
