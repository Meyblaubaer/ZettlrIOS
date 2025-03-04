struct ZettlrConfig {
    // Zettlr Desktop Einstellungen
    static let defaultSettings = [
        "fileExtension": "md",
        "frontMatterFormat": "yaml",
        "citationStyle": "chicago",
        "linkFormat": "wiki"
    ]
    
    // Sync-Einstellungen
    static let syncSettings = [
        "interval": 300, // 5 Minuten
        "conflictStrategy": "newerWins",
        "backupEnabled": true
    ]
} 