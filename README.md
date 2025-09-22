---

## Setup rapide - Cosmetic Manager

### Prérequis
- Docker Desktop (WSL2 activé)
- Node 20+ (ou 22) via NVM  
- npm ou pnpm
- (Optionnel) Git

### 1. Cloner & entrer dans le dossier
```bash
git clone <url> cosmetic-manager
cd cosmetic-manager
```

### 2. Démarrer Postgres (persistance incluse)
```bash
docker volume create cm_pgdata
docker run -d --name cm-postgres --restart unless-stopped \
  -e POSTGRES_USER=cm -e POSTGRES_PASSWORD=cm -e POSTGRES_DB=cosmetic \
  -p 5432:5432 -v cm_pgdata:/var/lib/postgresql/data postgres:16-alpine
```

**Note :** Si le port 5432 est pris, remplace par `-p 5433:5432` et adapte l'URL ci-dessous.

### 3. Configurer l'environnement
Créer un fichier `.env` à la racine :
```env
DATABASE_URL=postgres://cm:cm@localhost:5432/cosmetic
```

### 4. Installer les dépendances
```bash
# npm
npm install

# ou pnpm  
pnpm install
```

### 5. Drizzle (migrations)
```bash
# npm
npm run db:generate && npm run db:migrate

# pnpm
pnpm db:generate && pnpm db:migrate
```

### 6. Lancer l'app
```bash
# npm
npm run dev

# pnpm
pnpm dev
```

**Accéder à l'app :** http://localhost:3000/inventory

---

## Outils utiles

### Studio Drizzle
```bash
npm run db:studio
# ou 
pnpm db:studio
```

### Tester la connexion DB
```bash
docker exec -it cm-postgres psql -U cm -d cosmetic -c "\dt"
```

---

## Maintenance

### Voir les conteneurs
```bash
docker ps
```

### Logs
```bash
docker logs -f cm-postgres
```

### Stop / Start
```bash
docker stop cm-postgres
docker start cm-postgres
```

### Recréer sans perdre les données
```bash
docker rm -f cm-postgres
# puis relancer la commande docker run (le volume cm_pgdata garde les données)
```

### ⚠️ Reset total (attention, supprime les données)
```bash
docker rm -f cm-postgres
docker volume rm cm_pgdata
```