// build.js — exécuté par Vercel avant chaque déploiement
// Génère config.js à partir des variables d'environnement sécurisées
// (les clés ne sont jamais stockées dans le code source)

const fs = require('fs');

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_ANON_KEY;

if (!url || !key) {
    console.error('❌ Variables manquantes dans Vercel :');
    console.error('   → SUPABASE_URL');
    console.error('   → SUPABASE_ANON_KEY');
    console.error('   Ajoute-les dans Vercel : Settings > Environment Variables');
    process.exit(1);
}

const contenu = `// config.js — généré automatiquement au déploiement par build.js
// Ne pas modifier ce fichier manuellement
const SUPABASE_URL = '${url}';
const SUPABASE_ANON_KEY = '${key}';
`;

fs.writeFileSync('config.js', contenu);
console.log('✅ config.js généré avec succès');
