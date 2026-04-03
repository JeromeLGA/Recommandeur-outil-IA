# Journal des erreurs — Recommandeur d'Outils IA

Historique des erreurs rencontrées pendant le développement, avec cause et solution.

---

## ERR-01 — Boucle infinie de connexion (dashboard ↔ admin)

**Symptôme**
La page `dashboard.html` s'ouvre, repasse sur `admin.html`, revient sur `dashboard.html`, en boucle toutes les 0,5 secondes.

**Cause (local)**
`onAuthStateChange()` se déclenche une première fois avec `session = null` avant que Supabase ait fini de vérifier le token.

**Cause (production / Vercel)**
`getSession()` peut retourner `null` brièvement pendant l'initialisation sur Vercel, même si l'utilisateur est connecté.

**Solution définitive**
Utiliser `onAuthStateChange` avec l'événement `INITIAL_SESSION`, qui attend que Supabase ait complètement initialisé la session.

```javascript
// ✅ Fix production — à utiliser dans dashboard.html ET admin.html
db.auth.onAuthStateChange((event, session) => {
    if (event === 'INITIAL_SESSION') {
        if (!session) { window.location.href = 'admin.html'; }
        else { chargerDashboard(); }
    } else if (event === 'SIGNED_OUT') {
        window.location.href = 'admin.html';
    }
});

// ❌ Incorrect — provoque la boucle en production
db.auth.getSession().then(({ data: { session } }) => {
    if (!session) { window.location.href = 'admin.html'; }
});
```

---

## ERR-02 — Table "outils" créée avec seulement `id` + `created_at`

**Symptôme**
Toutes les requêtes d'import échouent avec :
`Could not find the 'category' column of 'outils' in the schema cache`

**Cause**
Supabase auto-crée la table avec seulement `id` et `created_at` avant que `supabase-setup.sql` soit lancé. `CREATE TABLE IF NOT EXISTS` ne modifie jamais une table existante.

**Solution**
```sql
DROP TABLE IF EXISTS outils;
-- Puis relancer supabase-setup.sql en entier
```

---

## ERR-03 — Cache de schéma Supabase désynchronisé

**Symptôme**
`Could not find the 'xxx' column of 'outils' in the schema cache` après création/modification d'une table.

**Cause**
PostgREST met en cache la structure des tables et ne la relit pas automatiquement.

**Solution**
```sql
NOTIFY pgrst, 'reload schema';
```
> Le bouton "Reload schema" dans Settings > API n'existe plus dans les nouvelles versions de Supabase.

---

## ERR-04 — `fetch('data.json')` échoue avec NetworkError

**Symptôme**
`❌ Erreur : NetworkError when attempting to fetch resource.` en cliquant "Prévisualiser" dans `import.html`.

**Cause**
`fetch()` est bloqué par le navigateur en protocole `file://`. Ne fonctionne qu'avec un serveur HTTP.

**Solution**
Toujours ouvrir via **Live Server** (VS Code), jamais par double-clic sur le fichier.

---

## ERR-05 — RLS activé sans règles = tout est bloqué

**Symptôme**
Toutes les requêtes Supabase échouent ou retournent un tableau vide.

**Cause**
"Enable automatic RLS" coché à la création du projet sans politique configurée. RLS bloque tout par défaut.

**Solution**
Ne pas cocher RLS à la création. L'activer manuellement avec les bonnes policies :
```sql
ALTER TABLE outils ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lecture_publique" ON outils FOR SELECT USING (true);
CREATE POLICY "ecriture_admin" ON outils FOR ALL USING (auth.role() = 'authenticated');
```

---

## ERR-06 — "Aucun outil trouvé" alors que la base est censée être remplie

**Symptôme**
`index.html` affiche "❌ Aucun outil trouvé" pour toutes les combinaisons de filtres.

**Cause**
Soit la table est vide (`import.html` pas encore lancé), soit une erreur Supabase silencieuse au chargement laisse `outils = []`.

**Solution**
- Vérifier la console du navigateur (F12) pour les erreurs Supabase
- Vérifier dans Supabase > Table Editor que la table contient des lignes
- Si vide : lancer `import.html` en mode "Mise à jour intelligente"
