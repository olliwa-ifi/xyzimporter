# wkt_reader.rb
module OlliwaPointsXYZ
  module PointsXYZ
    module WKTReader
        
        # Méthode principale qui lit, normalise et retourne les données
        def self.read_and_normalize(file_path)
        # 1. Lecture brute de toutes les géométries
        raw_geometries = read_file(file_path)
        return [] if raw_geometries.empty?

        # 2. Calcul des minima globaux
        min_x = Float::INFINITY
        min_y = Float::INFINITY
        min_z = Float::INFINITY

        raw_geometries.each do |geom|
            geom[:points].each do |pt|
            min_x = pt.x if pt.x < min_x
            min_y = pt.y < min_y ? pt.y : min_y
            min_z = pt.z < min_z ? pt.z : min_z
            end
        end

        # 3. Application du décalage (offset) pour ramener vers (0,0,0)
        raw_geometries.map do |geom|
            normalized_points = geom[:points].map do |pt|
            Geom::Point3d.new(pt.x - min_x, pt.y - min_y, pt.z - min_z)
            end
            { type: geom[:type], points: normalized_points }
        end
        end

        # Méthode interne de lecture (privée)
        def self.read_file(file_path)
        geometries = []
        File.open(file_path, "r") do |file|
            file.each_line do |line|
            line = line.strip
            next if line.empty?
            begin
                geometries << parse_wkt_line(line)
            rescue StandardError => e
                puts "Erreur ligne : #{e.message}"
            end
            end
        end
        geometries
        end

        def self.parse_wkt_line(line)
        case line
        when /^POINT\s*\((.*)\)/i
            points = parse_coordinates($1)
            { type: :point, points: [points.first] }
        when /^LINESTRING\s*\((.*)\)/i
            points = parse_coordinates($1)
            { type: :linestring, points: points }
        when /^POLYGON\s*\((.*)\)/i
            content = $1
            outer_ring = content.match(/\(([^)]+)\)/)[1]
            points = parse_coordinates(outer_ring)
            { type: :polygon, points: points }
        else
            raise "Format WKT non supporté"
        end
        end

        def self.parse_coordinates(coord_string)
        coord_string.split(',').map do |point_str|
            vals = point_str.strip.split(/\s+/)
            x = vals[0].to_f
            y = vals[1].to_f
            z = vals[2] ? vals[2].to_f : 0.0
            Geom::Point3d.new(x, y, z)
        end
        end
    end
  end
end