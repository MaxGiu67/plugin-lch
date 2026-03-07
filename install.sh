#!/usr/bin/env bash
# ============================================================================
# LinkedIn Content Hub — Plugin Installer
# Plugin Cowork per gestire contenuti LinkedIn via MCP
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PLUGIN_NAME="LinkedIn Content Hub"
SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LCH_SOURCE="$SCRIPT_DIR/skills"
LCH_SKILLS=(
  lch
)

ALL_PREFIXES=("lch")

info()    { echo -e "${BLUE}i${NC}  $1"; }
success() { echo -e "${GREEN}v${NC}  $1"; }
warn()    { echo -e "${YELLOW}!${NC}  $1"; }
error()   { echo -e "${RED}x${NC}  $1"; }

print_banner() {
  echo ""
  echo -e "${BOLD}=========================================${NC}"
  echo -e "${BOLD}  LinkedIn Content Hub — Plugin v1.0.0${NC}"
  echo -e "${BOLD}  Gestione contenuti LinkedIn via MCP${NC}"
  echo -e "${BOLD}=========================================${NC}"
  echo ""
}

check_prerequisites() {
  local has_errors=0

  if [ -d "$HOME/.claude" ]; then
    success "Claude Code rilevato (~/.claude/)"
  else
    error "Claude Code non rilevato. Installa Claude Code: https://claude.ai/code"
    has_errors=1
  fi

  if [ -d "$LCH_SOURCE" ]; then
    success "Sorgente plugin trovata"
  else
    error "Directory non trovata: $LCH_SOURCE"
    error "Esegui lo script dalla root del plugin"
    has_errors=1
  fi

  if [ "$has_errors" -eq 1 ]; then
    echo ""
    error "Prerequisiti mancanti. Correggi gli errori sopra e riprova."
    exit 1
  fi

  echo ""
}

install_plugin() {
  local mode="${1:-symlink}"

  print_banner
  info "Verifica prerequisiti..."
  echo ""
  check_prerequisites

  echo -e "${BOLD}-- Installazione skill Claude Code --${NC}"
  echo ""

  mkdir -p "$SKILLS_DIR"

  local existing=0
  for skill in "${LCH_SKILLS[@]}"; do
    if [ -e "$SKILLS_DIR/$skill" ] || [ -L "$SKILLS_DIR/$skill" ]; then
      existing=$((existing + 1))
    fi
  done

  if [ "$existing" -gt 0 ]; then
    warn "$existing skill gia' installate trovate"
    echo ""
    read -rp "Sovrascrivere? [s/N] " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
      info "Installazione annullata."
      exit 0
    fi
  fi

  local installed=0
  for skill in "${LCH_SKILLS[@]}"; do
    if [ -e "$SKILLS_DIR/$skill" ] || [ -L "$SKILLS_DIR/$skill" ]; then
      rm -rf "$SKILLS_DIR/$skill"
    fi
    if [ "$mode" = "copy" ]; then
      cp -r "$LCH_SOURCE/$skill" "$SKILLS_DIR/$skill"
    else
      ln -s "$LCH_SOURCE/$skill" "$SKILLS_DIR/$skill"
    fi
    installed=$((installed + 1))
  done

  if [ "$mode" = "copy" ]; then
    success "$installed skill copiate in $SKILLS_DIR/"
  else
    success "$installed skill linkate in $SKILLS_DIR/"
  fi

  echo ""
  echo -e "${GREEN}${BOLD}Installazione completata!${NC}"
  echo ""
  echo -e "${BOLD}Skill disponibili:${NC}"
  for skill in "${LCH_SKILLS[@]}"; do
    echo "  /$skill"
  done
  echo ""
  echo -e "${BOLD}Prossimi passi:${NC}"
  echo "  1. Riavvia Claude Code (chiudi e riapri la sessione)"
  echo "  2. Configura il server MCP in LinkedIn Content Hub (Settings > API Token)"
  echo "  3. Usa /lch per iniziare a gestire i tuoi contenuti LinkedIn"
  echo ""

  if [ "$mode" = "symlink" ]; then
    info "Modalita' symlink: le modifiche al repo si riflettono automaticamente."
  else
    info "Modalita' copia: per aggiornare, riesegui: bash install.sh --copy"
  fi
  echo ""
}

update_plugin() {
  print_banner
  info "Aggiornamento $PLUGIN_NAME..."
  echo ""

  if [ -d "$SCRIPT_DIR/.git" ]; then
    info "Aggiornamento repo da remote..."
    if git -C "$SCRIPT_DIR" pull --ff-only 2>/dev/null; then
      success "Repository aggiornato"
    else
      warn "git pull fallito — continuo con la versione locale"
    fi
    echo ""
  fi

  check_prerequisites

  mkdir -p "$SKILLS_DIR"

  local added=0
  local updated=0
  local unchanged=0

  for skill in "${LCH_SKILLS[@]}"; do
    if [ -L "$SKILLS_DIR/$skill" ]; then
      local current_target
      current_target=$(readlink "$SKILLS_DIR/$skill" 2>/dev/null || echo "")
      local expected_target="$LCH_SOURCE/$skill"

      if [ "$current_target" = "$expected_target" ]; then
        unchanged=$((unchanged + 1))
      else
        rm -f "$SKILLS_DIR/$skill"
        ln -s "$expected_target" "$SKILLS_DIR/$skill"
        updated=$((updated + 1))
        success "$skill — symlink aggiornato"
      fi
    elif [ -d "$SKILLS_DIR/$skill" ]; then
      rm -rf "$SKILLS_DIR/$skill"
      cp -r "$LCH_SOURCE/$skill" "$SKILLS_DIR/$skill"
      updated=$((updated + 1))
      success "$skill — aggiornato (copy)"
    else
      ln -s "$LCH_SOURCE/$skill" "$SKILLS_DIR/$skill"
      added=$((added + 1))
      success "$skill — NUOVA skill aggiunta"
    fi
  done

  echo ""
  [ "$added" -gt 0 ] && success "$added nuove skill aggiunte"
  [ "$updated" -gt 0 ] && success "$updated skill aggiornate"
  [ "$unchanged" -gt 0 ] && info "$unchanged skill gia' aggiornate"

  echo ""
  echo -e "${GREEN}${BOLD}Aggiornamento completato!${NC}"
  echo ""
  info "Riavvia Claude Code per applicare le modifiche."
  echo ""
}

uninstall_plugin() {
  print_banner
  info "Disinstallazione $PLUGIN_NAME..."
  echo ""

  local found=0
  for skill in "${LCH_SKILLS[@]}"; do
    if [ -e "$SKILLS_DIR/$skill" ] || [ -L "$SKILLS_DIR/$skill" ]; then
      found=$((found + 1))
    fi
  done

  if [ "$found" -eq 0 ]; then
    warn "Nessuna skill LCH trovata — nulla da rimuovere."
    echo ""
    return
  fi

  info "$found skill trovate"
  echo ""
  read -rp "Confermi la rimozione? [s/N] " confirm
  if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    info "Disinstallazione annullata."
    exit 0
  fi

  local removed=0
  for skill in "${LCH_SKILLS[@]}"; do
    if [ -e "$SKILLS_DIR/$skill" ] || [ -L "$SKILLS_DIR/$skill" ]; then
      rm -rf "$SKILLS_DIR/$skill"
      removed=$((removed + 1))
    fi
  done

  success "$removed skill rimosse da $SKILLS_DIR/"
  echo ""
  info "Riavvia Claude Code per completare la disinstallazione."
  echo ""
}

show_help() {
  print_banner
  echo "Uso:"
  echo "  bash install.sh              Installa skill (symlink, consigliato)"
  echo "  bash install.sh --copy       Installa con copia dei file"
  echo "  bash install.sh --update     Aggiorna: git pull + sync skill"
  echo "  bash install.sh --uninstall  Disinstalla il plugin"
  echo "  bash install.sh --help       Mostra questo messaggio"
  echo ""
  echo "Modalita':"
  echo "  symlink (default)  Link simbolici in ~/.claude/skills/"
  echo "                     Modifiche al repo riflesse automaticamente."
  echo "  copy (--copy)      Copia file in ~/.claude/skills/"
  echo "                     Rieseguire lo script per aggiornare."
  echo ""
}

case "${1:-}" in
  --update)
    update_plugin
    ;;
  --copy)
    install_plugin "copy"
    ;;
  --uninstall)
    uninstall_plugin
    ;;
  --help|-h)
    show_help
    ;;
  "")
    install_plugin "symlink"
    ;;
  *)
    error "Opzione non riconosciuta: $1"
    echo ""
    show_help
    exit 1
    ;;
esac
