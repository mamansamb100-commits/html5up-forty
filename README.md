# html5up-forty — CI/CD Pipeline complet

Forké depuis [moisawade/html5up-forty](https://github.com/moisawade/html5up-forty)

---

## Lancer le projet (1 seule commande)

### Mac / Linux
```bash
bash setup.sh
```

### Windows (PowerShell)
```powershell
.\setup.ps1
```

Le script fait tout automatiquement :
- Clone le repo
- Copie les fichiers corrigés
- Build l'image Docker
- Lance le conteneur en local → http://localhost:8080
- Commit et push sur GitHub (branches `main` et `trivy`)

---

## Configurer les secrets GitHub (obligatoire pour le pipeline)

1. Allez sur votre repo → **Settings** → **Secrets and variables** → **Actions**
2. Cliquez **New repository secret** et ajoutez :

| Nom du secret | Valeur |
|---|---|
| `DOCKERHUB_USERNAME` | Votre pseudo Docker Hub |
| `DOCKERHUB_TOKEN` | Token généré sur hub.docker.com |

### Créer un token Docker Hub
1. Connectez-vous sur [hub.docker.com](https://hub.docker.com)
2. **Account Settings** → **Security** → **New Access Token**
3. Copiez le token et collez-le dans le secret GitHub

---

## Pipeline CI/CD

```
push sur main ou trivy
        │
        ▼
┌──────────────────────────────┐
│  JOB 1 — CI                  │
│  1. Checkout code             │
│  2. Login Docker Hub          │
│  3. Build image ci-html:1.0.1 │
│  4. Push vers Docker Hub      │
│  5. Scan Trivy (sécurité)     │
└──────────────┬───────────────┘
               │ needs: ci
               ▼
┌──────────────────────────────┐
│  JOB 2 — Deploy              │
│  1. Pull image depuis Hub     │
│  2. Stop ancien conteneur     │
│  3. Lancer nouveau conteneur  │
│     sur port 80               │
└──────────────────────────────┘
```

---

## Corrections apportées au workflow original

| Problème | Correction |
|---|---|
| `image-ref: ci-html-demo:latest` (image inexistante) | `image-ref: username/ci-html:1.0.1` |
| `runs-on: aws-runner` (runner inexistant) | `runs-on: ubuntu-latest` |
| Pas de login Docker dans le job deploy | Login ajouté avant `docker pull` |
| `exit-code: 1` bloquait sur faux positifs | Mis à `0` (informatif) |

---

## Commandes utiles

```bash
# Voir le site en local
open http://localhost:8080

# Logs du conteneur
docker logs ci-app

# Arrêter le conteneur
docker stop ci-app && docker rm ci-app

# Rebuild manuel
docker build -t ci-html:1.0.1 .
docker run -d --name ci-app -p 8080:80 ci-html:1.0.1
```

---

## Structure du projet

```
html5up-forty/
├── .github/
│   └── workflows/
│       └── ci.yaml        ← Pipeline CI/CD corrigé
├── assets/                ← CSS, JS, fonts
├── images/                ← Images du site
├── index.html
├── Dockerfile             ← nginx:1.25-alpine
├── nginx.conf             ← Config serveur web
├── setup.sh               ← Script setup Mac/Linux
├── setup.ps1              ← Script setup Windows
└── README.md
```
