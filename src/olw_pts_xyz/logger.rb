module OlliwaPointsXYZ
  module PointsXYZ
    module PtsXYZLogger
      # Détermine le chemin absolu du fichier log basé sur le modèle actuel
      def self.log_path
        model = Sketchup.active_model
        # On récupère le dossier du fichier .skp enregistré, sinon le home de l'utilisateur
        base_dir = (model && model.path && !model.path.empty?) ? File.dirname(model.path) : Dir.home
        
        # CORRECTION : Accès complet via le chemin du module
        version = (defined?(OlliwaPointsXYZ::PointsXYZ::Config) && OlliwaPointsXYZ::PointsXYZ::Config::VERSION) || "0.0.0"
        
        File.expand_path(File.join(base_dir, "PointsXYZ_v#{version}.log"))
      end

      # Crée l'en-tête de session détaillé
      def self.write_header
        absolute_path = log_path
        # CORRECTION : Accès complet via le chemin du module
        version = (defined?(OlliwaPointsXYZ::PointsXYZ::Config) && OlliwaPointsXYZ::PointsXYZ::Config::VERSION) || "0.0.0"
        
        header = <<~HEADER
          
            ======================================================================
            SESSION START  : #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}
            Plugin Version : #{version} | SketchUp: #{Sketchup.version}
            LOG PATH (ABS) : #{absolute_path}
            ======================================================================
        HEADER
        log("SYSTEM", header)
      end

      # Méthode centrale de journalisation
      def self.log(level, msg, e = nil)
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        line = "[#{timestamp}] #{level}: #{msg}"
        
        if e
          line += "\n#{e.message}\n#{e.backtrace[0..3].join("\n")}"
        end
        
        puts line # Console Ruby
        
        begin
          File.open(log_path, 'a') { |f| f.puts line }
        rescue => err
          puts "Logging failed to #{log_path}: #{err.message}"
        end
      end

      # Raccourcis
      def self.info(msg);  log("INFO", msg); end
      def self.debug(msg); log("DEBUG", msg); end
      def self.warn(msg);  log("WARN", msg); end
      def self.error(msg, e = nil); log("ERROR", msg, e); end
    end
  end
end

# CORRECTION DE L'ALIAS : On utilise le chemin complet vers le module
PtsXYZLogger = OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger
