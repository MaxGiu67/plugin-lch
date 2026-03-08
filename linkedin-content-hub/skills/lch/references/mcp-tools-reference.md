# MCP Tools Reference — LinkedIn Content Hub

Server MCP endpoint: `POST /api/mcp`
Auth: Bearer token (creato da Settings > API Token)
Protocollo: MCP Streamable HTTP (stateless)
Rate limit: 60 req/min per token

---

## Post (11 tool)

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

### delete_post
Elimina un post DRAFT. Solo l'autore o Owner può eliminare.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

### add_comment
Aggiunge un commento a un post (opzionalmente come reply).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| content | string (1-1000) | si | Testo del commento |
| reply_to_id | UUID | no | ID commento padre (max 1 livello nesting) |

Ritorna: `comment_id`, `post_id`, `author`, `content_preview`, `created_at`

### unschedule_post
Riporta un post SCHEDULED ad APPROVED e libera lo slot (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

Ritorna: `post_id`, `status: APPROVED`, `slot_freed`

### duplicate_post
Clona un post esistente come nuova bozza DRAFT.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post sorgente |
| copy_image_prompts | boolean | no | Copia prompt immagini AI come PENDING (default false) |

Ritorna: `original_post_id`, `new_post_id`, `status: DRAFT`, `content_preview`, `image_prompts_copied`

---

## Piani editoriali (6 tool)

### create_plan
Crea un nuovo piano editoriale.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| name | string | si | Nome del piano |
| start_date | string (YYYY-MM-DD) | si | Data inizio |
| end_date | string (YYYY-MM-DD) | si | Data fine |
| description | string | no | Descrizione del piano |
| objective | string | no | Obiettivo del piano |
| cadence_days | int[] (0-6) | no | Giorni pubblicazione (0=Dom..6=Sab). Default: [1,3,5] Lun/Mer/Ven |
| cadence_times | string[] (HH:MM) | no | Orari pubblicazione. Default: ["09:00"] |

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
Genera slot automatici per un piano. Usa la cadenza del piano o override personalizzati. Solo piani IN_PREPARAZIONE.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |
| days_of_week | int[] (0-6) | no | Override giorni (aggiorna anche il piano) |
| times | string[] (HH:MM) | no | Override orari (aggiorna anche il piano) |
| theme_id | UUID | no | Tema da assegnare a tutti gli slot generati |

### assign_post_to_slot
Assegna un post a uno slot del piano senza cambiarne lo stato.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| slot_id | UUID | si | ID dello slot |

---

## Slot (3 tool)

### create_slot
Crea uno slot singolo a data/ora specifica. Per slot fuori dalla cadenza regolare.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |
| scheduled_at | ISO 8601 | si | Data e ora dello slot (es. "2026-03-15T14:30:00") |
| theme_id | UUID | no | Tema da assegnare |

### update_slot
Sposta uno slot a una nuova data/ora o cambia tema.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| slot_id | UUID | si | ID dello slot |
| scheduled_at | ISO 8601 | no | Nuova data/ora |
| theme_id | UUID | no | Nuovo tema |

### delete_slot
Elimina uno slot vuoto (senza post assegnato).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
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

## Engagement (3 tool)

### configure_engagement
Crea una campagna di engagement per un post pubblicato. I task vengono generati automaticamente per tutti i membri del team e collaboratori esterni.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post (deve essere PUBLISHED) |

Ritorna: `campaign_id`, `post_id`, `status: PENDING`, `tasks_created`

### activate_campaign
Attiva una campagna PENDING: genera messaggi AI personalizzati con Claude per ogni collaboratore e li invia via WhatsApp (solo Owner). Richiede un LLM Provider attivo.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| campaign_id | UUID | si | ID della campagna (deve essere PENDING) |

Ritorna: `campaign_id`, `status: ACTIVE`, `tasks_sent`, `tasks_total`, `errors`

Flusso tipico: `configure_engagement` → `activate_campaign` → `get_engagement_status`

### get_engagement_status
Stato della campagna di engagement per un post.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |

Ritorna: `campaign_id`, `status`, `tasks[]` (con `status`, `assignee`, `has_ai_message`, `completed_at`)

---

## Collaboratori (4 tool)

### list_collaborators
Lista collaboratori esterni del tenant (partecipano all'engagement via WhatsApp).

Nessun parametro richiesto.

### add_collaborator
Aggiunge un collaboratore esterno (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| name | string | si | Nome del collaboratore |
| whatsapp | string | si | Numero WhatsApp (es. "+393351234567") |

### update_collaborator
Aggiorna nome o WhatsApp di un collaboratore (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| collaborator_id | UUID | si | ID del collaboratore |
| name | string | no | Nuovo nome |
| whatsapp | string | no | Nuovo numero WhatsApp |

### delete_collaborator
Rimuove un collaboratore esterno (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| collaborator_id | UUID | si | ID del collaboratore |

---

## Calendario (1 tool)

### get_upcoming
Lista i prossimi post schedulati o pubblicati.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| days | int | no | Giorni futuri da includere (default 7) |

---

## Temi (4 tool)

### list_themes
Lista tutti i temi/pillar disponibili.

Nessun parametro richiesto. Ritorna: id, name, color, description.

### create_theme
Crea un nuovo tema/pillar per un piano editoriale (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| plan_id | UUID | si | ID del piano |
| name | string (1-50) | si | Nome del tema |
| color | hex (#RRGGBB) | no | Colore (default #6366F1) |
| description | string (max 200) | no | Descrizione |
| target_weight | int (0-100) | no | Peso target percentuale |

Ritorna: `theme_id`, `name`, `color`, `plan_name`

### update_theme
Aggiorna un tema (solo Owner).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| theme_id | UUID | si | ID del tema |
| name | string (1-50) | no | Nuovo nome |
| color | hex (#RRGGBB) | no | Nuovo colore |
| description | string (max 200) | no | Nuova descrizione |
| target_weight | int (0-100) | no | Nuovo peso target |

Ritorna: `theme_id`, `name`, `color`, `updated_at`

### delete_theme
Elimina un tema (solo Owner). Post e slot perdono il riferimento al tema (SetNull).

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| theme_id | UUID | si | ID del tema |

Ritorna: `theme_id`, `message`, `posts_unlinked`, `slots_unlinked`

---

## AI Immagini (1 tool)

### generate_image
Genera un'immagine AI per uno slot del post (0-2). Può richiedere fino a 10 min per provider asincroni.

| Parametro | Tipo | Required | Descrizione |
|-----------|------|----------|-------------|
| post_id | UUID | si | ID del post |
| slot_index | int (0-2) | si | Indice slot immagine |
| prompt | string (1-2000) | si | Prompt per generazione |
| provider_id | UUID | no | ID provider AI (usa il primo attivo se omesso) |

Ritorna: `post_id`, `slot_index`, `status`, `image_url`, `provider_name`, `duration_ms`

---

## Utility (3 tool)

### get_dashboard
Statistiche overview: conteggi post per stato, piani, prossimi post schedulati.

Nessun parametro richiesto.

Ritorna: `counts` (plans, posts_total, draft, in_review, approved, scheduled, published, failed), `upcoming_posts` (next 7 days, max 10)

### get_me
Profilo utente corrente e stato token LinkedIn.

Nessun parametro richiesto.

Ritorna: `user` (id, name, email, role, avatar_url, linkedin_id), `linkedin_token` (status, days_remaining, expires_at)

### get_costs
Costi generazione AI del tenant: immagini AI, messaggi LLM, WhatsApp.

Nessun parametro richiesto.

Ritorna: `ai_images` (totalUsd, totalGenerations, successCount, failureCount, avgCostUsd, avgDurationMs, byProvider[], recentLogs[]), `llm` (totalUsd, totalGenerations, successCount, failureCount, avgCostUsd, avgDurationMs, byProvider[], recentLogs[]), `whatsapp` (totalMessages, totalCost, last30days), `period` (from, to)

---

## Totale: 41 tool

| Categoria | Count |
|-----------|-------|
| Post | 11 |
| Piani editoriali | 6 |
| Slot | 3 |
| Revisione | 3 |
| Engagement | 3 |
| Collaboratori | 4 |
| Calendario | 1 |
| Temi | 4 |
| AI Immagini | 1 |
| Utility | 3 |
| **Totale** | **41** |
