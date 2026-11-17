# -------------------------------------------------------------------------
# Module Core : Logique de traitement et création des objets SketchUp
# -------------------------------------------------------------------------

module OlliwaPointsXYZ
  module PointsXYZ
    module Core

      def self.import_xyz(data, options)
        model = Sketchup.active_model
        entities = model.active_entities
        
        group_name = "Import_XYZ_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
        main_definition = model.definitions.add(group_name)
        instance = entities.add_instance(main_definition, Geom::Point3d.new(0, 0, 0))
        comp_entities = main_definition.entities
        
        # Unité pour la conversion .m, .cm, .mm
        unit_method = options[:unit].to_s.strip
        # Valeur du décalage pour le label
        d_val = options[:d_label].to_f
        
        # On crée le vecteur de décalage une seule fois
        # Ce vecteur définit la direction et la longueur de la flèche
        offset_vector = Geom::Vector3d.new(d_val, 0, d_val)
        
        points_count = 0
        errors_count = 0

        data.each_with_index do |row, index|
          if row.length < 3
            PtsXYZLogger.info("Ligne #{index + 1} ignorée : colonnes insuffisantes.")
            errors_count += 1
            next
          end

          if row.length >= 4
            raw_label, x_str, y_str, z_str = row[0], row[1], row[2], row[3]
          else
            raw_label, x_str, y_str, z_str = "", row[0], row[1], row[2]
          end

          label = raw_label.empty? ? "Point_#{index + 1}" : raw_label

          begin
            # Conversion via mécanismes SketchUp 2020 (.to_f.m, .to_f.cm, etc.)
            x = x_str.to_f.send(unit_method)
            y = y_str.to_f.send(unit_method)
            z = z_str.to_f.send(unit_method)
          rescue => e
            PtsXYZLogger.error("Erreur de conversion .#{unit_method} ligne #{index + 1}: #{e.message}", e)
            errors_count += 1
            next
          end

          # 1. Création du point (CPoint)
          point_pos = Geom::Point3d.new(x, y, z)
          comp_entities.add_cpoint(point_pos)

          # 2. Ajout du texte avec flèche
          # Signature API: add_text(string, point, vector)
          # point : la pointe de la flèche (le point XYZ)
          # vector : le décalage pour positionner le texte et créer la flèche
          comp_entities.add_text(label.to_s, point_pos, offset_vector)

          points_count += 1
        end

        PtsXYZLogger.info("Import terminé : #{points_count} points créés, #{errors_count} erreurs.")
        ::UI.messagebox("Importation terminée !\nPoints créés : #{points_count}\nErreurs : #{errors_count}")
      end

    end
  end
end

PtsXYZCore = OlliwaPointsXYZ::PointsXYZ::Core
