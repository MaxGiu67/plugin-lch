# Changelog

## [0.2.0] - 2026-03-07

### Aggiunto
- 3 nuovi tool MCP: `create_slot`, `update_slot`, `delete_slot` (CRUD slot personalizzati)
- `create_plan`: parametri `cadence_days` e `cadence_times` per cadenza personalizzata
- `generate_slots`: override giorni/orari + assegnazione tema massiva
- Reference aggiornata a 23 tool MCP

### Modificato
- Reference mcp-tools-reference.md aggiornata con nuovi tool e parametri

---

## [0.1.0] - 2026-03-07

### Aggiunto
- Skill `/lch` per gestione completa contenuti LinkedIn
- Agente "Marco" Content Strategist LinkedIn
- Riferimento completo 20 tool MCP (posts, piani, revisioni, engagement, calendario, temi)
- Workflow: creazione post, piano editoriale, revisione, scheduling, pubblicazione
- Supporto prompt immagini AI (fino a 3 per post)
- Scheduling esclusivamente da slot del piano editoriale
- `install.sh` con supporto symlink/copy/update/uninstall
- Struttura marketplace Cowork compatibile
