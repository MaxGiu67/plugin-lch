# LinkedIn Content Hub — Plugin Cowork

Plugin per Claude Code che permette di gestire piani editoriali, post LinkedIn, revisioni e scheduling tramite il server MCP di LinkedIn Content Hub.

## Installazione

```bash
git clone <repo-url> plugin-lch
cd plugin-lch
bash install.sh
```

Opzioni:
- `bash install.sh` — installa con symlink (consigliato)
- `bash install.sh --copy` — installa con copia file
- `bash install.sh --update` — aggiorna
- `bash install.sh --uninstall` — disinstalla

## Configurazione

1. Apri LinkedIn Content Hub (web app)
2. Vai in **Settings > API Token**
3. Crea un nuovo token
4. Configura il token nel server MCP come Bearer token

## Uso

In Claude Code, digita:

```
/lch
```

Marco, il Content Strategist, ti guidera' nella gestione dei contenuti.

### Esempi

```
/lch crea un post sulla leadership nel settore tech
/lch mostra il piano editoriale Q1
/lch revisiona i post in attesa
/lch schedula i post approvati
/lch dashboard
```

## Funzionalita'

- **Piani editoriali** — Crea piani trimestrali con temi e slot
- **Creazione post** — Post LinkedIn ottimizzati con hook, CTA, hashtag
- **Immagini AI** — Genera fino a 3 prompt per immagini AI per post
- **Revisione** — Flusso di approvazione/rifiuto strutturato
- **Scheduling** — Schedula post negli slot del piano editoriale
- **Pubblicazione** — Pubblica direttamente su LinkedIn
- **Dashboard** — Panoramica stato contenuti e calendario

## Requisiti

- Claude Code installato
- LinkedIn Content Hub configurato e accessibile
- API Token valido

## Licenza

MIT
