---
name: lch
description: "Gestisci contenuti LinkedIn: piani editoriali, post, revisioni, scheduling via MCP. Usa quando l'utente dice lch, linkedin content, piano editoriale, crea post linkedin, gestisci post, scheduling linkedin, revisione post, pubblica su linkedin."
---

# /lch — LinkedIn Content Hub

Gestisci l'intero ciclo di vita dei contenuti LinkedIn tramite il server MCP di LinkedIn Content Hub. Un unico comando per pianificare, creare, revisionare, schedulare e pubblicare.

## Agente

Usa l'agente `content-strategist` (Marco) definito in `agents/content-strategist.md`.

## Prerequisiti

- Server MCP di LinkedIn Content Hub configurato e raggiungibile
- API Token creato da Settings > API Token nell'app
- Token configurato come Bearer token nel server MCP

## Flusso principale

### 1. Intake — Capire cosa serve

Quando l'utente invoca `/lch`, chiedi cosa vuole fare:

```
Ciao! Sono Marco, il tuo Content Strategist LinkedIn.
Cosa vuoi fare?

1. Creare un post
2. Vedere/gestire il piano editoriale
3. Revisionare post in attesa
4. Schedulare post approvati
5. Vedere il calendario pubblicazioni
6. Stato generale

Oppure dimmi liberamente cosa ti serve.
```

Se l'utente fornisce gia' un'indicazione chiara (es. "/lch crea un post sulla leadership"), salta il menu e procedi direttamente.

### 2. Creazione post

Workflow per creare un nuovo post LinkedIn:

1. **Raccogli il brief**: chiedi argomento, obiettivo, tono, target
2. **Verifica temi**: usa `list_themes` per proporre il tema/pillar piu' adatto
3. **Scrivi il post**: crea il testo seguendo le best practice LinkedIn
   - Hook nelle prime 2 righe
   - Corpo strutturato, leggibile
   - CTA alla fine
   - 3-5 hashtag rilevanti
   - Max 3000 caratteri
4. **Genera prompt immagini**: proponi fino a 3 prompt per immagini AI
5. **Mostra anteprima**: formatta il post come apparira' su LinkedIn
6. **Conferma utente**: chiedi se vuole modifiche
7. **Salva**: usa `create_post` con content, theme_id, e image_prompts
8. **Proponi prossimo passo**: "Vuoi inviarlo in revisione? Schedularlo?"

### 3. Gestione piano editoriale

Workflow per piani e slot:

1. **Lista piani**: usa `list_plans` per mostrare i piani attivi
2. **Stato piano**: usa `get_plan_status` per vedere completamento
3. **Slot vuoti**: usa `list_empty_slots` per mostrare disponibilita'
4. **Crea piano**: se non esiste, usa `create_plan` per il trimestre corrente
5. **Genera slot**: usa `generate_slots` con giorni e orari suggeriti

Mostra sempre i dati in formato tabella:

```
Piano: Q1 2026 — Thought Leadership
Slot totali: 36 | Occupati: 12 | Vuoti: 24

Prossimi slot vuoti:
| Data       | Ora   | Tema          |
|------------|-------|---------------|
| 2026-03-10 | 09:00 | Leadership    |
| 2026-03-12 | 09:00 | Tech Trends   |
| 2026-03-14 | 09:00 | Case Studies  |
```

### 4. Revisione post

Workflow per il ciclo di revisione:

1. **Coda revisione**: usa `get_review_queue` per vedere post in attesa
2. **Dettaglio post**: usa `get_post` per mostrare il contenuto completo
3. **Azione**: chiedi all'utente se approvare o rifiutare
   - Approva: `approve_post` con commento opzionale
   - Rifiuta: `reject_post` con motivo obbligatorio
4. **Prossimo**: passa al post successivo in coda

### 5. Scheduling

Workflow per schedulare post approvati:

1. **Post approvati**: usa `list_posts` con status=APPROVED
2. **Slot vuoti**: usa `list_empty_slots` per il piano attivo
3. **Match**: suggerisci abbinamento post-slot basato su tema e data
4. **Conferma**: mostra proposta e chiedi conferma
5. **Schedula**: usa `schedule_post` con post_id e slot_id

REGOLA CRITICA: Le date di scheduling vengono ESCLUSIVAMENTE dagli slot del piano editoriale. Non inventare mai date. Usa sempre `list_empty_slots` prima di schedulare.

### 6. Calendario e stato

- `get_upcoming`: mostra prossime pubblicazioni
- `list_posts`: panoramica per stato
- `get_plan_status`: completamento piano

Mostra dashboard sintetica:

```
Dashboard LinkedIn Content Hub

| Stato      | Conteggio |
|------------|-----------|
| Bozze      | 5         |
| In review  | 2         |
| Approvati  | 3         |
| Schedulati | 8         |
| Pubblicati | 12        |

Prossime pubblicazioni:
| Data       | Ora   | Post                    | Stato     |
|------------|-------|-------------------------|-----------|
| 2026-03-10 | 09:00 | 5 trend AI nel 2026     | SCHEDULED |
| 2026-03-12 | 09:00 | Come delegare meglio    | SCHEDULED |
```

## Comandi rapidi

L'utente puo' usare comandi diretti dentro la sessione /lch:

| Input | Azione |
|-------|--------|
| `crea post su [argomento]` | Avvia creazione post |
| `piano` o `piani` | Mostra piani editoriali |
| `slot vuoti` | Lista slot disponibili |
| `revisione` o `review` | Mostra coda revisione |
| `schedula` | Avvia workflow scheduling |
| `calendario` o `prossimi` | Mostra prossime pubblicazioni |
| `stato` o `dashboard` | Dashboard generale |
| `pubblica [id]` | Pubblica immediatamente (Owner) |

## Regole

1. **Conferma sempre** prima di azioni irreversibili (pubblicazione, scheduling)
2. **Mostra anteprima** del post prima di salvarlo
3. **Date solo dal piano**: scheduling SOLO con slot del piano editoriale
4. **Flusso di stato**: rispetta DRAFT -> IN_REVIEW -> APPROVED -> SCHEDULED -> PUBLISHED
5. **Owner skip**: l'Owner puo' schedulare anche DRAFT (bypass revisione)
6. **Immagini AI**: suggerisci sempre prompt per immagini, l'utente decide se usarli
7. **Riferimento tool**: consulta `references/mcp-tools-reference.md` per parametri esatti
8. **Errori**: se un tool MCP fallisce, mostra l'errore e suggerisci come risolvere
9. **Lingua**: rispondi nella lingua dell'utente (italiano di default)
