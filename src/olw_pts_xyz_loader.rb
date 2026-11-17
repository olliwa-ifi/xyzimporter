require 'sketchup.rb'
require 'extensions.rb'

module OlliwaPointsXYZ
  module PointsXYZ
    # 1. CONFIGURATION ET LOGGER
    plugin_dir = File.join(File.dirname(__FILE__), 'olw_pts_xyz')

    module PtsXYZLogger
      def self.log(msg, lvl=:info); puts "[#{lvl.to_s.upcase}] PointsXYZ: #{msg}"; end
      def self.debug(msg); log(msg, :debug); end
      def self.error(msg); log(msg, :error); end
    end

    begin
      require File.join(plugin_dir, 'logger.rb')
      logger = defined?(OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger) ? OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger : PtsXYZLogger
      logger.info("==============================================")
      logger.info("Début du chargement du plugin Olliwa Point XYZ")
    rescue LoadError
      PtsXYZLogger.log("Utilisation du logger de secours (logger.rb introuvable)", :info)
      logger = PtsXYZLogger
    rescue => e
      PtsXYZLogger.log("Erreur lors du chargement du logger : #{e.message}", :error)
      logger = PtsXYZLogger
    end

    # 2. VÉRIFICATION DE LA VERSION MINIMALE
    SKETCHUP_MIN_VERSION = 20.0
    
    if Sketchup.version.to_f < SKETCHUP_MIN_VERSION
      ::UI.messagebox("Le plugin nécessite SketchUp 2020 ou une version plus récente.")
    else
      # 3. CHARGEMENT SÉQUENTIEL DES FICHIERS
      files = ['config.rb', 'read-csv.rb', 'core.rb', 'ui.rb']

      files.each do |file|
        begin
          path = File.join(plugin_dir, file)
          require path
          logger.debug("Chargement réussi : #{file}")
        rescue LoadError => e
          logger.error("Impossible de charger #{file}. Détails : #{e.message}")
        rescue StandardError => e
          logger.error("Erreur critique dans #{file} : #{e.message}")
        end
      end
      logger.info("==============================================")
      if defined?(OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger) && OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger.respond_to?(:write_header)
        OlliwaPointsXYZ::PointsXYZ::PtsXYZLogger.write_header
      end
        
      # 4. CRÉATION DES MENUS (Accès direct dans 'Plugins')
      unless file_loaded?(__FILE__)
        begin
          version_label = (defined?(OlliwaPointsXYZ::PointsXYZ::Config) && OlliwaPointsXYZ::PointsXYZ::Config::VERSION) rescue "0.0.0"
          
          # Définition du texte d'aide pour éviter la répétition
          HELP_TEXT = <<~TEXT
            Guide d'utilisation :
            L'outil permet d'importer un jeu de points en coordonnées locales XYZ.
            1. Sélectionner votre fichier CSV ou txt (label, x, y, z)).
            2. Choisir l'unité des données (m, cm, mm) et les séparateurs de champs et de décimales.
            3. Validez pour générer les points.
          TEXT

          # On ajoute les items directement au menu 'Plugins' sans sous-menu
          plugins_menu = ::UI.menu('Plugins')
          
          # Action : Lancer l'outil (Aide puis Import)
          plugins_menu.add_item("Olliwa Points XYZ v#{version_label}") {
            logger.info("Lancement : Flux Aide -> Import")
            ::UI.messagebox(HELP_TEXT, 64, "Guide d'utilisation")
            begin
              OlliwaPointsXYZ::PointsXYZ::UI.show_import_dialog
            rescue => e
              logger.error("Erreur critique UI : #{e.message}")
              puts e.message
              puts e.backtrace # <--- Ajoutez ceci pour voir la pile d'appels
              puts e.message
              puts e.backtrace # <--- Ajoutez ceci pour voir la pile d'appels

            end
          }
          
          # Action : Aide directe
          #plugins_menu.add_item("Olliwa Points XYZ : Aide") {
          #  logger.info("Accès direct à l'aide")
          #  ::UI.messagebox(HELP_TEXT, 64, "Guide d'utilisation")
          #}
          
          file_loaded(__FILE__)
          logger.info("Items ajoutés directement au menu 'Plugins'")
        rescue => e
          logger.error("Erreur lors de la création du menu : #{e.message}")
        end
      end
    end
  end
end

version_label = "1.0.0"
begin
  version_label = OlliwaPointsXYZ::PointsXYZ::Config::VERSION
rescue
end

extension_name = "Olliwa Points XYZ v#{version_label}"
ext = SketchupExtension.new(extension_name, __FILE__)
ext.description = "Importer Points XYZ pour SketchUp"
ext.creator = "Olliwa"
Sketchup.register_extension(ext)
