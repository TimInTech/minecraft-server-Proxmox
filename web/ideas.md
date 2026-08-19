# Designideen: Minecraft Server auf Proxmox – Dokumentation

## Drei Gestaltungsrichtungen

### Ansatz 1

**Themenname:** Forge Ledger

**Kurzidee:** Eine technische Werkbank als Dokumentationsoberfläche: helle Papierflächen, dunkle Werkstattnavigation und sorgfältig gesetzte Statusmarken schaffen Vertrauen und Orientierung.

**Wahrscheinlichkeit:** 0.07

### Ansatz 2

**Themenname:** Obsidian Console

**Kurzidee:** Eine ruhige, dunkle Operations-Konsole mit warmen Ember-Akzenten übersetzt Proxmox- und Minecraft-Themen in eine fokussierte Leselandschaft.

**Wahrscheinlichkeit:** 0.04

### Ansatz 3

**Themenname:** Alpine Runbook

**Kurzidee:** Ein redaktionelles Handbuch in kühlem Stein und Nadelgrün verbindet technische Präzision mit der Atmosphäre eines verlässlichen Homelab-Betriebshandbuchs.

**Wahrscheinlichkeit:** 0.09

## Gewählter Ansatz: Forge Ledger

### Designbewegung

Die Website folgt dem **Technical Editorial / Workshop Ledger**: Sie verbindet die klare Informationshierarchie hochwertiger Betriebsdokumentation mit der materiellen Wirkung einer Werkbank aus dunklem Basalt, warmem Kupfer und hellem Archivpapier.

### Kernprinzipien

1. Inhalt trägt die Oberfläche: Jede dekorative Ebene macht Quellen, Status oder Navigation leichter lesbar.
2. Kontrast schafft Betriebsruhe: dunkle Navigations- und Diagnoseflächen rahmen helle Lesebereiche mit langen Textstrecken.
3. Status ist semantisch: Grün bedeutet verifiziert, Bernstein bedeutet Einschränkung, Rot bleibt Fehlern und Risiken vorbehalten.
4. Asymmetrie dient Orientierung: Eine feste linke Schiene führt durch das Dokument, während der Inhalt rechts als redaktionelles Arbeitsblatt fließt.

### Farbphilosophie

Basalt und tiefes Anthrazit geben der Seite die Schwere eines Homelab-Racks. Ein warmes, eigenständiges **Forge Copper** schafft Wiedererkennung und lenkt zu Entscheidungen und interaktiven Elementen. Helles, leicht warmes Papier verbessert die Langstreckenlesbarkeit; Grüntöne treten nur als echte Verifikationssignale auf.

### Layoutparadigma

Die Website ist als vertikales Runbook angelegt. Desktop-Nutzende lesen an einer festen linken Inhaltsleiste entlang einer breiten, gestaffelten Dokumentfläche; wichtige Entscheidungen stehen als seitlich versetzte Prüfkarten. Auf Mobilgeräten wird die Schiene zu einer kompakten Kapitelzeile über dem Inhalt.

### Signatur-Elemente

1. Ein kupferfarbenes, aus drei versetzten Blöcken konstruiertes Markenzeichen, das VM, LXC und Server abstrahiert.
2. Feine, grafitfarbene Rasterlinien und eine transparente Papierspur im Inhaltsbereich.
3. Statuschips im Stil technischer Prüfplaketten mit schmaler linker Farbkante.

### Interaktionsphilosophie

Die Seite reagiert wie ein gutes Runbook: Suche und Kapitelwechsel sind direkt und ohne visuelles Warten. Hover-Zustände sind zurückhaltend und präzise; Interaktionen bestätigen sich über Kontrast, eine kleine Verschiebung und klare Statussprache.

### Animation

Beim Laden staffeln sich Navigationsschiene, Überschrift und Prüfkarten leicht mit maximal 220 ms. Suchresultate wechseln per Opazität und minimaler vertikaler Bewegung. Alle Bewegungen respektieren `prefers-reduced-motion`; Fokus, Suche und Tastaturnavigation bleiben instant.

### Typografiesystem

**Space Grotesk** setzt Titel, Kennzahlen und Navigation mit klaren technischen Proportionen. **Source Serif 4** trägt die längeren dokumentarischen Absätze und sorgt für ein handbuchartiges Lesegefühl. **JetBrains Mono** reserviert sich für Revisionen, Pfade, Commands und Prüfwerte.

### Markenidentität

**Positionierung:** Ein prüfbares, durchsuchbares Betriebsdokument für Homelab-Anwender, die Minecraft-Server auf Proxmox nachvollziehbar vorbereiten wollen.

**Persönlichkeit:** Präzise, belastbar, unaufgeregt.

### Markenstimme

Überschriften formulieren Entscheidungen und Befunde statt allgemeiner Begrüßungen. CTAs beschreiben eine konkrete Navigation oder Prüfung.

Beispiele:

> „Bereit für eine sichere Demo – ohne Systemänderung."

> „Prüfgrenzen verstehen, bevor ein Host verändert wird."

### Wortmarke und Logo

Das Logo ist ein textloses, kupferfarbenes Blockzeichen auf transparentem Grund: drei leicht versetzte isometrische Quader bilden einen nach oben offenen Serverstapel. Die Wortmarke entsteht im Interface aus „FORGE“ in Space Grotesk und „LEDGER“ in JetBrains Mono mit weit gesperrten Buchstaben.

### Signaturfarbe

**Forge Copper – `#C9783A`**. Dieser Ton ist für Markenzeichen, aktive Navigationspunkte und handlungsorientierte Elemente reserviert.

## Style Decisions

- Die Desktopansicht nutzt eine dauerhaft sichtbare Ledger-Schiene mit Kapitelstatus und Revisionsmetadaten; sie ist Teil des Dokumentlayouts, nicht bloß schwebende Navigation.
- Das kupferfarbene Drei-Block-Zeichen und die Wortmarke erscheinen im ersten Bildschirm als Prüf- und Interface-Siegel.
- Hero-Bildwelten werden durch sichtbare Nachweisstreifen, Quellenkennzeichen und Runbook-Metadaten als Dokumentationswerkbank gerahmt.
- Statuschips, Prüfkarten und Quellenzeilen erhalten eine gemeinsame linke Signalkante, Monospace-Metadaten und semantische Farben.
