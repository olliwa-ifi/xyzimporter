# -------------------------------------------------------------------------
# Module pour lire et nettoyer les données XYZ provenant d'un fichier CSV/TXT
# -------------------------------------------------------------------------
require 'csv'

module OlliwaPointsXYZ
  module PointsXYZ
    module ReadCsv

      # Méthode principale de lecture
      def self.parse_xyz_csv(file_path, col_sep, dec_sep, skip_lines = 0)
        points_data = []

        begin
          CSV.foreach(file_path, headers: false, skip_blanks: true, col_sep: col_sep) do |row|
            
            next if $. <= skip_lines

            # CORRECTION : On supprime .compact
            # On utilise .map et on gère le nil à l'intérieur pour ne pas décaler les colonnes
            clean_row = row.map do |value|
              # On transforme en string et on strip, même si la valeur est nil
              val = value.to_s.strip
              
              # Gestion du séparateur décimal
              if dec_sep != '.' && val.include?(dec_sep)
                val = val.gsub(dec_sep, '.')
              end
              
              val
            end

            # On vérifie que la ligne a bien le nombre de colonnes attendu (Label, X, Y, Z)
            # On accepte 3 si le label est absent, mais Core devra gérer le décalage.
            # Le plus sûr est d'exiger que la structure soit respectée.
            points_data << clean_row if clean_row.length >= 3
          end
        rescue Errno::ENOENT
          ::UI.messagebox("Le fichier est introuvable : #{file_path}")
          return nil
        rescue => e
          ::UI.messagebox("Erreur lors de la lecture du fichier :\n#{e.message}")
          return nil
        end

        return points_data
      end

    end
  end
end

PtsXYZReadCsv = OlliwaPointsXYZ::PointsXYZ::ReadCsv
