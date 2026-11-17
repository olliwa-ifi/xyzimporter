module OlliwaPointsXYZ
  module PointsXYZ
    class UI
      SCHEMA = {
        unit:      { prompt: "Unités du fichier:",      default: "m",     list: "m|cm|mm", type: :string },
        d_label:   { prompt: "Décalage Label (cm):",    default: "3.0",    list: nil, type: :float },
        col_sep:   { prompt: "Séparateur colonnes:",     default: "virgule", list: "virgule|point virgule|tabulation", type: :string },
        dec_sep:   { prompt: "Séparateur décimal:",      default: "point",   list: "point|virgule", type: :string },
        skip_lines: { prompt: "Lignes à sauter au début:", default: "1",    list: nil, type: :integer }
      }.freeze

      CONVERSION_MAP = {
        "virgule" => ",",
        "point virgule" => ";",
        "tabulation" => "\t",
        "point" => "."
      }.freeze

      def self.show_import_dialog
        file_path = ::UI.openpanel("Sélectionner le fichier XYZ/CSV", "", "Fichiers XYZ/CSV|*.csv;*.txt|Tous les fichiers|*.*||")
        return unless file_path

        preview_text = get_file_preview(file_path)
        ::UI.messagebox(preview_text, MB_MULTILINE, "Aperçu du fichier")

        prompts = SCHEMA.values.map { |v| v[:prompt] }
        defaults = SCHEMA.values.map { |v| v[:default] }
        lists = SCHEMA.values.map { |v| v[:list] }
        
        input = ::UI.inputbox(prompts, defaults, lists, "Importation : #{File.basename(file_path)}")
        return unless input

        user_data = SCHEMA.keys.zip(input).to_h
        validated_params = validate_and_sanitize(user_data)
        
        data = PtsXYZReadCsv.parse_xyz_csv(
          file_path, 
          validated_params[:col_sep], 
          validated_params[:dec_sep], 
          validated_params[:skip_lines]
        )

        return if data.nil? || data.empty?

        OlliwaPointsXYZ::PointsXYZ::Core.import_xyz(data, validated_params)
      end

      private

      def self.get_file_preview(path)
        lines = []
        begin
          File.open(path, "r") do |f|
            3.times { lines << f.gets }
          end
        rescue => e
          return "Erreur lors de la lecture du fichier : #{e.message}"
        end
        preview = lines.compact.map(&:strip).join("\n")
        preview.empty? ? "Le fichier est vide." : "Contenu des 3 premières lignes :\n#{preview}"
      end

      def self.validate_and_sanitize(user_data)
        validated = {}
        user_data.each do |key, value|
          config = SCHEMA[key]
          case config[:type]
          when :float then validated[key] = value.to_f
          when :integer then validated[key] = value.to_i
          when :string
            val = value.to_s.strip
            validated[key] = (key == :unit) ? val : (CONVERSION_MAP[val] || val)
          end
        end
        validated
      end
    end
  end
end
