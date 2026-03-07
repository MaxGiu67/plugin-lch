# MCP Tools Reference — LinkedIn Content Hub

Server MCP endpoint: `POST /api/mcp`
Auth: Bearer token (creato da Settings > API Token)
Protocollo: MCP Streamable HTTP (stateless)
Rate limit: 60 req/min per token

---

## Post (7 tool)

### create_post
Crea un nuovo post LinkedIn come bozza.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| content | string (1-3000) | si | Testo del post |
| title | string (max 100) | no | Titolo opzionale |
| theme_id | UUID | no | ID del tema/pillar |
| scheduled_at | ISO 8601 | no | Data di scheduling |
| notes | string | no | Note interne |
| image_prompts | string[] (max 3) | no | Prompt per generazione immagini AI (1 per slot) |

Ritorna: `post_id`, `status`, `content_preview`, `created_at`, `image_prompts_saved`

### update_post
Aggiorna un post esistente (solo DRAFT o REJECTED).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| content | string (max 3000) | no | Nuovo contenuto |
| title | string (max 100) | no | Nuovo titolo |
| theme_id | UUID | no | Nuovo tema |

### list_posts
Lista post con filtri opzionali.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| status | string | no | Filtro per stato (DRAFT, IN_REVIEW, APPROVED, SCHEDULED, PUBLISHED, etc.) |
| theme_id | UUID | no | Filtro per tema |
| limit | int (1-50) | no | Max risultati (default 20) |

### get_post
Dettaglio completo di un post (con revisioni, commenti, tema, slot).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

### submit_for_review
Invia un post in revisione (DRAFT/REJECTED -> IN_REVIEW).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

### schedule_post
Schedula un post per pubblicazione. La data viene dallo slot del piano editoriale.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| slot_id | UUID | si | ID dello slot (usa `list_empty_slots` per trovarne uno) |

IMPORTANTE: Le date di scheduling vengono SOLO dagli slot del piano editoriale. Non si possono usare date arbitrarie.

### publish_now
Pubblica un post immediatamente (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

---

## Piani editoriali (6 tool)

### create_plan
Crea un nuovo piano editoriale trimestrale.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| name | string | si | Nome del piano |
| quarter | int (1-4) | si | Trimestre |
| year | int | si | Anno |

### list_plans
Lista tutti i piani editoriali.

Nessun parametro richiesto.

### get_plan_status
Stato dettagliato di un piano (slot totali, occupati, vuoti, post per stato).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |

### list_empty_slots
Lista gli slot vuoti disponibili per scheduling.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |
| limit | int | no | Max risultati |

### generate_slots
Genera slot automatici per un piano.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |
| days_of_week | int[] | si | Giorni della settimana (0=dom, 1=lun, ..., 6=sab) |
| time | string (HH:MM) | si | Ora di pubblicazione |
| theme_id | UUID | no | Tema da assegnare agli slot |

### assign_post_to_slot
Assegna un post a uno slot del piano senza cambiarne lo stato.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| slot_id | UUID | si | ID dello slot |

---

## Revisione (3 tool)

### get_review_queue
Lista post in attesa di revisione.

Nessun parametro richiesto. Ritorna post con status IN_REVIEW.

### approve_post
Approva un post in revisione (IN_REVIEW -> APPROVED).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| comment | string | no | Commento opzionale |

### reject_post
Rifiuta un post in revisione (IN_REVIEW -> REJECTED).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| comment | string | si | Motivo del rifiuto |

---

## Engagement (2 tool)

### configure_engagement
Configura una campagna di engagement post-pubblicazione.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post (deve essere PUBLISHED) |
| replies | string[] | no | Template di risposte ai commenti |
| follow_up | string | no | Messaggio di follow-up |

### get_engagement_status
Stato della campagna di engagement per un post.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

---

## Calendario (1 tool)

### get_upcoming
Lista i prossimi post schedulati o pubblicati.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| days | int | no | Giorni futuri da includere (default 7) |

---

## Temi (1 tool)

### list_themes
Lista tutti i temi/pillar disponibili.

Nessun parametro richiesto. Ritorna: id, name, color, description.
