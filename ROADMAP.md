# ZettlrIOS Entwicklungs-Roadmap

## Phase 1: Grundlegende Verbesserungen (Q2 2024)

### 1.1 Markdown-Editor-Erweiterungen
- [ ] **LaTeX-Integration**
  - Integration von KaTeX/MathJax für mathematische Formeln
  - Inline-LaTeX-Unterstützung
  - LaTeX-Vorschau im Editor

- [ ] **Erweiterte Editor-Funktionen**
  - Tabellen-Editor mit Touch-Unterstützung
  - Fußnoten-Verwaltung
  - Verbesserte Code-Block-Darstellung mit Syntax-Highlighting
  - Auto-Vervollständigung für Markdown-Syntax

- [ ] **WYSIWYG-Verbesserungen**
  - Live-Vorschau im Split-View
  - Anpassbare Vorschau-Stile
  - Echtzeit-Rendering von Formeln und Diagrammen

### 1.2 Dateimanagement
- [ ] **Hierarchische Struktur**
  - Implementierung einer Ordnerstruktur
  - Drag & Drop für Dateien und Ordner
  - Datei-Tagging-System

- [ ] **Import/Export**
  - PDF-Export mit LaTeX-Unterstützung
  - HTML-Export
  - Markdown-Import aus verschiedenen Quellen
  - Batch-Export-Funktionen

## Phase 2: Akademische Funktionen (Q3 2024)

### 2.1 Zitations-System
- [ ] **Zotero-Integration**
  - Anbindung an Zotero API
  - Zitations-Picker
  - BibTeX-Unterstützung

- [ ] **Bibliographie-Management**
  - Lokale Bibliothek
  - Zitierstil-Auswahl (CSL)
  - Automatische Literaturverzeichnisse

### 2.2 Erweiterte Analyse
- [ ] **Statistik-Dashboard**
  - Wort- und Zeichenzählung
  - Lesbarkeits-Analyse
  - Schreibziele und Fortschritt
  - Tag-Analyse und Visualisierung

## Phase 3: Zettelkasten-Erweiterungen (Q4 2024)

### 3.1 Verknüpfungssystem
- [ ] **Erweiterte Wiki-Links**
  - ID-basierte Verlinkung
  - Automatische Backlink-Aktualisierung
  - Link-Vorschläge basierend auf Kontext
  - Visuelle Link-Vorschau

- [ ] **Graph-Visualisierung**
  - Interaktiver Wissensgraph
  - Filter- und Suchmöglichkeiten
  - Cluster-Analyse
  - Export von Graphen

### 3.2 Wissensmanagement
- [ ] **Erweiterte Suche**
  - Volltextsuche mit Fuzzy-Matching
  - Semantische Suche
  - Filter nach Metadaten
  - Gespeicherte Suchanfragen

## Phase 4: Synchronisation & Integration (Q1 2025)

### 4.1 Desktop-Kompatibilität
- [ ] **Zettlr Desktop Sync**
  - Kompatibles Dateiformat
  - Konfliktauflösung
  - Selektive Synchronisation
  - Offline-Modus

### 4.2 Versionierung
- [ ] **Git-Integration**
  - Basis Git-Operationen
  - Commit-Historie
  - Branch-Management
  - Merge-Konflikt-Auflösung

## Phase 5: Benutzeroberfläche & Anpassung (Q2 2025)

### 5.1 UI-Verbesserungen
- [ ] **Mehrfenster-Unterstützung**
  - Split-View auf iPad
  - Drag & Drop zwischen Fenstern
  - Kontextmenüs
  - Tastaturkürzel

- [ ] **Themes & Anpassung**
  - Benutzerdefinierte Themes
  - CSS-Unterstützung
  - Anpassbare Toolbars
  - Dark/Light Mode Optimierung

### 5.2 Lokalisierung
- [ ] **Mehrsprachigkeit**
  - Interface-Übersetzungen
  - Lokalisierte Dokumentation
  - Rechtschreibprüfung für mehrere Sprachen

## Phase 6: Erweiterbarkeit (Q3 2025)

### 6.1 Plugin-System
- [ ] **Plugin-Architektur**
  - Plugin-API
  - Plugin-Marketplace
  - Sicherheits-Sandbox
  - Update-Mechanismus

### 6.2 Automatisierung
- [ ] **Shortcuts-Integration**
  - iOS Shortcuts-Unterstützung
  - Automatisierte Workflows
  - Batch-Operationen
  - Skript-Unterstützung

## Zettlr Desktop Kompatibilität

### Kompatibilitätsschicht

#### 1. Dateimodell-Anpassungen
```swift
struct Note {
    // Bestehende Felder
    var id: UUID
    var title: String
    var content: String
    
    // Neue Felder für Zettlr-Kompatibilität
    var filePath: String           // Relativer Pfad im Zettlr-Workspace
    var lastModifiedOnDesktop: Date
    var zettlrId: String          // Zettlr-spezifische ID
    var frontMatter: [String: Any] // YAML Front Matter
}
```

#### 2. Synchronisationsmanagement
```swift
class ZettlrSyncManager {
    enum SyncStrategy {
        case cloudKit    // Für iOS-only Nutzung
        case fileSystem  // Für Zettlr Desktop Kompatibilität
        case hybrid      // Beide Systeme
    }
    
    func configureSyncStrategy(_ strategy: SyncStrategy) {
        switch strategy {
        case .fileSystem:
            // Direkter Zugriff auf Zettlr-Dateisystem
            setupFileSystemWatcher()
        case .hybrid:
            // Kombinierte Synchronisation
            setupHybridSync()
        default:
            // Standard CloudKit
            setupCloudKitSync()
        }
    }
}
```

#### 3. Markdown-Verarbeitung
```swift
class MarkdownProcessor {
    // Zettlr-spezifische Markdown-Erweiterungen
    func processZettlrMarkdown(_ content: String) -> NSAttributedString {
        // Unterstützung für:
        // - YAML Front Matter
        // - LaTeX-Blöcke
        // - Zettlr-spezifische Links
        // - Zitations-Syntax
    }
}
```

### Implementierungsphasen

#### Phase A: Grundlegende Kompatibilität (Q2 2024)
- [ ] **Dateistruktur-Anpassung**
  - Implementierung der Zettlr-Ordnerstruktur
  - YAML Front Matter Integration
  - Dateinamen-Konventionen

- [ ] **Basis-Synchronisation**
  - Dateisystem-Watcher
  - Konfliktmanagement
  - Backup-Strategien

#### Phase B: Feature-Kompatibilität (Q3 2024)
- [ ] **Markdown-Erweiterungen**
  - LaTeX-Support
  - Zettlr-spezifische Syntax
  - Link-Format-Konvertierung

- [ ] **Metadaten-Management**
  - Tag-System-Integration
  - ID-System-Angleichung
  - Attribut-Mapping

#### Phase C: Erweiterte Integration (Q4 2024)
- [ ] **Zitations-System**
  - Zotero-Kompatibilität
  - BibTeX-Integration
  - CSL-Styles-Support

- [ ] **Such-System**
  - Globale Suche
  - Filter-Kompatibilität
  - Index-Synchronisation

### Konfiguration

```yaml
# Zettlr-Kompatibilitäts-Konfiguration
zettlr:
  workspace:
    root: "~/Documents/Zettlr"
    structure:
      - notes
      - attachments
      - templates
    metadata:
      format: "yaml"
      required:
        - id
        - tags
        - created
```

### Konfliktmanagement

```swift
class ConflictResolver {
    enum ConflictStrategy {
        case newerWins
        case desktopPriority
        case mobilePriority
        case manual
    }
    
    func resolveConflict(local: Note, remote: Note, strategy: ConflictStrategy) {
        // Intelligente Konfliktlösung zwischen Desktop und Mobile
    }
}
```

### Technische Voraussetzungen für Kompatibilität

1. **Dateisystem**
   - Implementierung von FileProvider
   - Dokumenttyp-Registrierung
   - Datei-Koordination

2. **Netzwerk**
   - Offline-Fähigkeit
   - Sync-Queuing
   - Bandwidth-Management

3. **Sicherheit**
   - Verschlüsselte Speicherung
   - Sichere Übertragung
   - Berechtigungsmanagement

### Integration-KPIs

1. **Kompatibilität**
   - 100% Markdown-Syntax-Kompatibilität
   - Vollständige Metadaten-Übertragung
   - Fehlerfreie Link-Konvertierung

2. **Performance**
   - Sync-Zeit < 2 Sekunden
   - Konfliktrate < 1%
   - Speichereffizienz

3. **Benutzerfreundlichkeit**
   - Nahtlose Integration
   - Transparente Synchronisation
   - Klare Fehlermeldungen

### Risiken & Mitigationen

1. **Technische Risiken**
   - Inkompatible Änderungen in Zettlr Desktop
   - Performance-Probleme bei großen Repositories
   - Sync-Konflikte

2. **Mitigationsstrategien**
   - Regelmäßige Kompatibilitätstests
   - Inkrementelle Synchronisation
   - Automatische Konfliktlösung

## Technische Voraussetzungen

### Infrastruktur
1. **CloudKit-Optimierung**
   - Verbesserte Konfliktauflösung
   - Effiziente Datensynchronisation
   - Backup-Strategien

2. **Performance**
   - Lazy Loading für große Dokumente
   - Caching-Strategien
   - Speicheroptimierung

3. **Sicherheit**
   - Ende-zu-Ende-Verschlüsselung
   - Sichere Datenspeicherung
   - Zugriffskontrollen

## Meilensteine & KPIs

### Q2 2024
- Basis LaTeX-Unterstützung
- Hierarchische Dateistruktur
- Verbesserter Editor

### Q3 2024
- Zitations-System
- Statistik-Dashboard
- Export-Funktionen

### Q4 2024
- Erweitertes Verknüpfungssystem
- Verbesserte Suche
- Graph-Visualisierung 2.0

### Q1 2025
- Desktop-Sync
- Git-Integration
- Versionierung

### Q2 2025
- Mehrfenster-Unterstützung
- Theme-System
- Lokalisierung

### Q3 2025
- Plugin-System
- Automatisierung
- API-Stabilisierung

## Ressourcenbedarf

### Entwicklung
- iOS-Entwickler (2-3)
- UI/UX-Designer (1)
- Backend-Entwickler (1)
- QA-Engineer (1)

### Infrastruktur
- CI/CD-Pipeline
- TestFlight-Distribution
- Analytics-System
- Dokumentations-Platform

## Risiken & Abhängigkeiten

### Technische Risiken
- CloudKit-Limitierungen
- iOS-Plattform-Änderungen
- Performance bei großen Dokumenten

### Projekt-Risiken
- Ressourcenverfügbarkeit
- Zeitplan-Verzögerungen
- Technische Schulden

---

*Letzte Aktualisierung: März 2024*
