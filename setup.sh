#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  SETUP COMPLET — html5up-forty
#  Ce script fait TOUT :
#    1. Vérifie Docker et Git
#    2. Clone votre fork GitHub
#    3. Copie les fichiers corrigés
#    4. Build et teste Docker en local
#    5. Commit et push vers GitHub (main + trivy)
#
#  Usage : bash setup.sh
# ═══════════════════════════════════════════════════════════════════

set -e

# ── CONFIG — modifiez ces deux lignes ──────────────────────────────
GITHUB_USERNAME="mamansamb100-commits"
DOCKERHUB_USERNAME=""           # votre username Docker Hub (optionnel pour le test local)
# ──────────────────────────────────────────────────────────────────

REPO="html5up-forty"
GITHUB_URL="https://github.com/$GITHUB_USERNAME/$REPO.git"
PORT=8080

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     SETUP COMPLET — html5up-forty CI/CD Lab          ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ─── ÉTAPE 1 : Vérification des outils ────────────────────────────
echo "── Étape 1 : Vérification des outils ──"

if ! command -v git &>/dev/null; then
  err "Git n'est pas installé. Installez-le depuis https://git-scm.com"
fi
log "Git installé : $(git --version)"

if ! docker info &>/dev/null 2>&1; then
  err "Docker n'est pas lancé. Démarrez Docker Desktop et relancez ce script."
fi
log "Docker actif : $(docker --version)"

echo ""

# ─── ÉTAPE 2 : Clone du repo GitHub ───────────────────────────────
echo "── Étape 2 : Clone du fork GitHub ──"

if [ -d "$REPO" ]; then
  warn "Dossier $REPO déjà existant — on travaille dedans."
  cd "$REPO"
else
  info "Clonage de $GITHUB_URL ..."
  git clone "$GITHUB_URL"
  cd "$REPO"
  log "Repo cloné"
fi

echo ""

# ─── ÉTAPE 3 : Copie des fichiers corrigés ────────────────────────
echo "── Étape 3 : Mise en place des fichiers ──"

# Créer les dossiers nécessaires
mkdir -p .github/workflows assets images

# Copier les fichiers depuis le dossier où ce script est lancé
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in Dockerfile nginx.conf; do
  if [ -f "$SCRIPT_DIR/$f" ]; then
    cp "$SCRIPT_DIR/$f" .
    log "Copié : $f"
  else
    warn "$f non trouvé dans $SCRIPT_DIR — ignoré"
  fi
done

if [ -f "$SCRIPT_DIR/.github/workflows/ci.yaml" ]; then
  cp "$SCRIPT_DIR/.github/workflows/ci.yaml" .github/workflows/ci.yaml
  log "Copié : .github/workflows/ci.yaml"
fi

echo ""

# ─── ÉTAPE 4 : Build Docker local ─────────────────────────────────
echo "── Étape 4 : Build Docker local ──"

IMAGE="ci-html"
TAG="1.0.1"

info "Construction de l'image $IMAGE:$TAG ..."
docker build -t "$IMAGE:$TAG" .
log "Image construite : $IMAGE:$TAG"

# Vérification
docker image ls | grep "$IMAGE"

echo ""

# ─── ÉTAPE 5 : Test local du conteneur ────────────────────────────
echo "── Étape 5 : Test du conteneur en local ──"

# Stopper l'ancien si existant
if docker ps -a --format '{{.Names}}' | grep -q "^ci-app$"; then
  docker stop ci-app >/dev/null 2>&1 || true
  docker rm   ci-app >/dev/null 2>&1 || true
  warn "Ancien conteneur supprimé"
fi

docker run -d --name ci-app -p $PORT:80 "$IMAGE:$TAG"
sleep 2

if docker ps | grep -q "ci-app"; then
  log "Conteneur ci-app démarré sur le port $PORT"
else
  err "Le conteneur n'a pas démarré — vérifiez les logs : docker logs ci-app"
fi

echo ""

# ─── ÉTAPE 6 : Git — commit et push ───────────────────────────────
echo "── Étape 6 : Git commit et push ──"

# Vérifier qu'il y a des changements
git add -A

if git diff --cached --quiet; then
  warn "Pas de nouveaux changements à committer."
else
  git commit -m "feat: ajout pipeline CI/CD Docker + Trivy + corrections workflow

- Correction image-ref Trivy (ci-html:1.0.1)
- Correction runs-on deploy (ubuntu-latest)
- Ajout Dockerfile nginx:1.25-alpine
- Ajout nginx.conf avec headers sécurité
- Pipeline : CI (build+push+scan) → CD (deploy)"

  log "Commit créé"

  # Push sur main
  git push origin main
  log "Push sur main effectué"
fi

echo ""

# ─── ÉTAPE 7 : Branche trivy ──────────────────────────────────────
echo "── Étape 7 : Création de la branche trivy ──"

if git branch -a | grep -q "trivy"; then
  info "Branche trivy déjà existante"
  git checkout trivy
  git merge main --no-edit || true
  git push origin trivy
  log "Branche trivy mise à jour"
else
  git checkout -b trivy
  git push origin trivy
  log "Branche trivy créée et poussée"
fi

git checkout main

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅  TOUT EST EN PLACE !                             ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║                                                      ║"
echo "║  🐳 Site local    : http://localhost:$PORT             ║"
echo "║  🐙 GitHub        : github.com/$GITHUB_USERNAME/$REPO  ║"
echo "║  🔀 Branches      : main  +  trivy                   ║"
echo "║                                                      ║"
echo "║  Prochaine étape → configurer les secrets GitHub :   ║"
echo "║  Settings > Secrets > Actions                        ║"
echo "║    • DOCKERHUB_USERNAME                              ║"
echo "║    • DOCKERHUB_TOKEN                                 ║"
echo "║                                                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Commandes utiles :"
echo "  Logs conteneur : docker logs ci-app"
echo "  Arrêter        : docker stop ci-app && docker rm ci-app"
echo ""
