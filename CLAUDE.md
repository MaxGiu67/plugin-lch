# LinkedIn Content Hub — Plugin Cowork

Plugin per gestire l'intero ciclo di vita dei contenuti LinkedIn tramite il server MCP di LinkedIn Content Hub.

## Struttura

```
plugin-lch/
├── .claude-plugin/
│   └── plugin.json              # Manifest plugin
├── agents/
│   └── content-strategist.md    # Marco — agente Content Strategist
├── skills/
│   └── lch/
│       ├── SKILL.md             # Skill principale /lch
│       └── references/
│           └── mcp-tools-reference.md  # Documentazione 20 tool MCP
├── install.sh                   # Script di installazione
├── CLAUDE.md                    # Questo file
└── README.md                    # Documentazione utente
```

## Architettura

Il plugin comunica con LinkedIn Content Hub attraverso il **server MCP** (Model Context Protocol):

```
Claude Code ─── /lch skill ──→ MCP Server ──→ LinkedIn Content Hub DB
                                    │
                                    └──→ LinkedIn API (pubblicazione)
```

- **Trasporto**: MCP Streamable HTTP (stateless)
- **Auth**: Bearer token (creato da Settings > API Token)
- **Endpoint**: `POST /api/mcp`
- **Rate limit**: 60 req/min per token

## Skill disponibili

| Skill | Comando | Descrizione |
|-------|---------|-------------|
| lch | `/lch` | Gestione completa contenuti LinkedIn |

## Tool MCP disponibili (20)

### Post (7)
`create_post`, `update_post`, `list_posts`, `get_post`, `submit_for_review`, `schedule_post`, `publish_now`

### Piani (6)
`create_plan`, `list_plans`, `get_plan_status`, `list_empty_slots`, `generate_slots`, `assign_post_to_slot`

### Revisione (3)
`get_review_queue`, `approve_post`, `reject_post`

### Engagement (2)
`configure_engagement`, `get_engagement_status`

### Calendario (1)
`get_upcoming`

### Temi (1)
`list_themes`

## Concetti chiave

### Gerarchia piano editoriale
Piano trimestrale → Temi/Pillar → Slot (data+ora) → Post

### Ciclo di vita post
```
DRAFT → IN_REVIEW → APPROVED → SCHEDULED → PUBLISHING → PUBLISHED
                  ↘ REJECTED → DRAFT (rielaborazione)
```

### Regola scheduling
Le date di scheduling vengono ESCLUSIVAMENTE dagli slot del piano editoriale. Usare sempre `list_empty_slots` prima di `schedule_post`.

### Ruoli
- **OWNER**: controllo completo, puo' bypassare revisione
- **EDITOR**: crea e modifica post
- **REVIEWER**: approva/rifiuta post
- **EDITOR_REVIEWER**: entrambi i ruoli

## Convenzioni

- Lingua documentazione: italiano
- Identificatori codice: inglese
- Formato date: ISO 8601
- ID: UUID v4
- Contenuto post: max 3000 caratteri
- Immagini AI: max 3 prompt per post
