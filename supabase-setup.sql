-- ============================================================
-- SUPABASE SETUP — Recommandeur d'Outils IA
-- ============================================================
-- Comment utiliser ce fichier :
--   1. Va sur supabase.com → ton projet
--   2. Clique sur "SQL Editor" dans le menu gauche
--   3. Colle tout ce fichier et clique sur "Run"
-- ============================================================


-- ------------------------------------------------------------
-- ÉTAPE 1 : Créer la table "outils"
-- ------------------------------------------------------------
-- C'est l'équivalent de la collection Firestore "outils".
-- En SQL, on définit à l'avance les colonnes et leur type.

CREATE TABLE IF NOT EXISTS outils (
    id            TEXT PRIMARY KEY,         -- identifiant unique, ex: "text_01"
    name          TEXT NOT NULL,            -- nom de l'outil
    category      TEXT NOT NULL,            -- catégorie (Texte & Rédaction, etc.)
    cost_model    TEXT,                     -- modèle tarifaire (texte libre)
    complexity    INTEGER CHECK (complexity BETWEEN 1 AND 10),
    quality_score INTEGER CHECK (quality_score BETWEEN 1 AND 10),
    risk_level    TEXT,                     -- Faible / Moyen / Élevé
    description   TEXT,
    website       TEXT,
    has_free_tier BOOLEAN DEFAULT false,    -- version gratuite disponible ?
    pro_price     TEXT,                     -- prix affiché, ex: "20$/mois"
    votes         INTEGER DEFAULT 0,        -- système de votes (Semaine 8)
    logo_url      TEXT                      -- URL du logo (Supabase Storage)
);


-- ------------------------------------------------------------
-- ÉTAPE 2 : Autoriser la lecture publique
-- ------------------------------------------------------------
-- Par défaut, Supabase autorise tout via la clé "anon"
-- TANT QUE le RLS (Row Level Security) n'est pas activé.
-- On n'active pas le RLS pour l'instant (comme convenu).
--
-- Si tu l'actives plus tard, décommente ces lignes :

-- ALTER TABLE outils ENABLE ROW LEVEL SECURITY;
--
-- -- Tout le monde peut lire les outils
-- CREATE POLICY "lecture_publique" ON outils
--     FOR SELECT USING (true);
--
-- -- Seul un utilisateur connecté peut écrire
-- CREATE POLICY "ecriture_admin" ON outils
--     FOR ALL USING (auth.role() = 'authenticated');


-- ------------------------------------------------------------
-- ÉTAPE 3 : Créer le bucket Storage pour les logos
-- ------------------------------------------------------------
-- Cette partie ne peut pas se faire en SQL.
-- Fais-le manuellement dans l'interface Supabase :
--
--   1. Menu gauche → "Storage"
--   2. Clique "New bucket"
--   3. Nom : logos
--   4. Coche "Public bucket" (pour que les logos soient accessibles)
--   5. Clique "Save"


-- ------------------------------------------------------------
-- ÉTAPE 4 : Créer le compte admin
-- ------------------------------------------------------------
-- Cette partie ne peut pas se faire en SQL non plus.
-- Fais-le manuellement dans l'interface Supabase :
--
--   1. Menu gauche → "Authentication"
--   2. Clique "Add user" → "Create new user"
--   3. Entre ton email et un mot de passe fort
--   4. Clique "Create user"
--
-- C'est ce compte que tu utiliseras pour te connecter sur admin.html


-- ------------------------------------------------------------
-- VÉRIFICATION
-- ------------------------------------------------------------
-- Après avoir lancé ce script, tu peux vérifier que la table
-- a bien été créée en tapant dans l'éditeur SQL :

-- SELECT * FROM outils;
-- (Doit retourner 0 lignes pour l'instant — c'est normal)
