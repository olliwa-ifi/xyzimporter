![Version](https://img.shields.io/badge/version-1.0.2-blue)
![Platform](https://img.shields.io/badge/platform-SketchUp-orange)
![Language](https://img.shields.io/badge/language-Ruby-red)


# Points XYZ / CSV Importer

Plugin pour SketchUp 2020 permettant l'importation rapide de points à partir de fichiers texte (XYZ ou CSV). Le plugin convertit les coordonnées brutes en points de construction (`CPoints`) et ajoute des labels avec flèches de rappel.

## 🚀 Fonctionnalités

- **Importation Flexible** : Support des fichiers `.csv`, `.txt` et `.xyz`.
- **Gestion des Séparateurs** : Configuration personnalisable du séparateur de colonnes (virgule, point-virgule, tabulation) et du séparateur décimal (point, virgule).
- **Conversion d'Unités Native** : Intégration des mécanismes de conversion de SketchUp 2020 (`.m`, `.cm`, `.mm`).
- **Labels Automatisés** : Création de labels pour chaque point avec un décalage configurable en X et Z pour garantir la visibilité des flèches de rappel.
- **Saut de Lignes** : Option pour ignorer les lignes d'en-tête du fichier.
- **Journalisation** : Intégration de `PtsXYZLogger` pour le suivi des erreurs d'importation et le debug session.

## 🛠 Installation

1. Copiez le dossier `olw_pts_xyz` dans le dossier Plugins de SketchUp :
   - **Windows** : `%AppData%\SketchUp\SketchUp 2020\SketchUp\Plugins`
   - **Mac** : `~/Library/Application Support/SketchUp 2020/SketchUp/Plugins`
2. Redémarrez SketchUp.

## 📖 Guide d'utilisation

1. Lancez l'outil d'importation via le menu du plugin.
2. Sélectionnez votre fichier source.
3. **Aperçu** : Une boîte de dialogue affiche les 3 premières lignes du fichier pour vous aider à identifier les séparateurs utilisés.
4. **Configuration** :
   - **Unités du fichier** : Choisissez l'unité (`m`, `cm`, `mm`). Le plugin traitera la valeur numérique comme étant dans cette unité.
   - **Décalage Label** : Définit la distance (en cm) entre le point et le texte. Le décalage est appliqué en X et Z pour générer la flèche.
   - **Séparateurs** : Adaptez selon le format de votre fichier (CSV standard, export Excel, etc.).
   - **Lignes à sauter** : Indiquez le nombre de lignes d'en-tête à ignorer.
5. Validez pour générer les points dans un nouveau composant dédié.

## ⚙️ Spécifications Techniques

### Architecture
- **UI Module** : Gestion de l'interface, validation des paramètres et prévisualisation du fichier.
- **ReadCsv Module** : Parsing robuste des fichiers texte avec nettoyage des caractères et gestion des séparateurs décimaux.
- **Core Module** : Logique de création d'objets SketchUp. Utilisation de `send(unit_method)` pour appeler dynamiquement les conversions `.m`, `.cm` ou `.mm`.

### Gestion des Labels
L'importation utilise la signature `add_text(string, point, vector)` de l'API SketchUp. 
- Le **point** est la position exacte du point XYZ.
- Le **vecteur** est un décalage diagonal `(d_val, 0, d_val)`, ce qui force l'affichage du leader (la flèche) pointant vers le point XYZ.

## 📝 Notes de version
- **Compatibilité** : SketchUp 2020.

