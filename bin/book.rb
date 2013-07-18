#!/usr/bin/env ruby
#coding: utf-8

require 'yaml'
require 'mini_magick'
require 'prawn'

class Array
   alias :пере :each
end

class Array
   def to_h options = {}
      h = {}
      self.each do |v|
         if v.is_a? Array
            if h.key? v[ 0 ]
               if !h[ v[ 0 ] ].is_a? Array
                  h[ v[ 0 ] ] = [ h[ v[ 0 ] ] ] ; end

               if v.size > 2
                  h[ v [ 0 ] ].concat v[ 1..-1 ]
               else
                  h[ v [ 0 ] ] << v[ 1 ] ; end
            else
               h[ v[ 0 ] ] = v.size > 2 && v[ 1..-1] || v[ 1 ]
            end
         else
            if h.key? v
               if !h[ v ].is_a? Array
                  h[ v ] = [ h[ v ] ] ; end

               h[ v ] << v
            else
               h[ v ] = nil
            end
         end
      end

      if options.key? :save_uniq
         h.each_pair do |k,v|
            if v.is_a? Array
               v.uniq!
            end
         end
      end

      h
   end
end

FileUtils.mkdir_p './tmp'
FileUtils.mkdir_p './tmp/djvu'
FileUtils.mkdir_p './tmp/pdf'

s = YAML.load( IO.read './share/settings.yml' )

s[ 'книги' ].each_pair do |book, value|
   flist = []

   (set, chapter, section) = [ nil, nil, nil ]
   value.пере do |page|
      puts "PAGE: #{page}"
      if page =~ /(.*)\.(.*)\.(.*)\.(.*)/
         ( set, chapter, glas, section ) = [ $1.to_i - 1, $2.to_i, $3, $4 ]
      elsif page =~ /(.*)\.(.*)\.(.*)/
         ( set, chapter, glas, section ) = [ $1.to_i - 1, $2.to_i, nil, $3 ]
      elsif page =~ /(.*)\.(.*)/
         ( set, chapter, glas, section ) = [ $1.to_i - 1, nil, nil, $2 ]; end
      if !set
         next; end

      dir = "./share/букы/#{s[ 'наборы' ][ set ]}/#{chapter}/"
      puts "DIR: #{dir.inspect}"

      clist = begin
         Dir.foreach( dir ).sort.map do |file|
            if file =~ /(?:(\d)\. )?(\d?\d\d\d)\.xcf$/
               [ [ $1, $2.to_i ], [ $1, file ] ]
            end
         end.compact.to_h
      rescue Errno::ENOENT
         puts "Error: #{$!} ro #{$@.join("\n")}"
         nil
      end
      puts "TEMP LIST #{clist.inspect}"

      section.split( /,/ ).each do |sec|
         if sec =~ /(\d+)-(\d+)/
            ($1.to_i..$2.to_i).each do |i|
               begin
                  flist << File.join( dir, clist[ [ glas, i ] ][ 1 ] )
               rescue
                  puts "Error: #{$!} ro #{$@.join("\n")}"
               end
            end
         elsif sec =~ /(\d+)/
            begin
               flist << File.join( dir, clist[ [ glas, $1.to_i ] ][ 1 ] )
            rescue
               puts "Error: #{$!} ro #{$@.join("\n")}"
            end
         end
      end
   end

   puts "FILES: #{flist.inspect}"
   FileUtils.rm_f [ "./tmp/#{book}.djvu" ]

   pdf = Prawn::Document.new(
         :page_size => "A0",
         :margin => 0,
         :info => {
            :Title => book,
            :Author => "Various authors",
            :Subject => "Знаменный роспев",
            :Keywords => "znamen,sing",
            :Creator => "Malo Skrylevo",
            :Producer => "Prawn",
            :CreationDate => Time.now } )
   pdf.text "Суточный круг богослужения. Знаменный роспев", :size => 18, :align => :center
#   pdf.bounding_box( [0, pdf.cursor], :width => 2384, :height => 3371 ) do
      pdf.fill_color "dcd1bf"
      pdf.fill_polygon [ 0, 0 ], [ 2383, 0 ], [ 2383, 3370 ], [ 0, 3370 ]
#   end
   pdf.text "Суточный круг богослужения. Знаменный роспев", :size => 18, :align => :center

   flist.each_index do |i|
      xcf = flist[ i ]
      puts "FILE: #{xcf}"

#      2512x3552 image size
      tmp = './tmp/output.ppm'
      xcf_image = MiniMagick::Image.open xcf
      bg_image = MiniMagick::Image.new tmp

      command = MiniMagick::CommandBuilder.new 'convert -background'
      command.push 'rgb(221,209,191)'
      command.push '-flatten'
      command.push xcf_image.path
      command.push bg_image.path
      bg_image.run command

#      `cpaldjvu -dpi 150 -colors 4 '#{tmp}' './tmp/djvu/page-#{sprintf "%.4i", i}.djvu'`
      `cpaldjvu -dpi 150 -colors 4 '#{tmp}' './tmp/output.djvu'`
      if File.exist?( "./tmp/#{book}.djvu" )
         `djvm -c './tmp/#{book}.djvu' './tmp/#{book}.djvu' ./tmp/output.djvu`
      else
         `djvm -c './tmp/#{book}.djvu' ./tmp/output.djvu`
      end

      #pdf
      tmp_image = MiniMagick::Image.open tmp
      png_image = MiniMagick::Image.new "./tmp/output.png"

      command = MiniMagick::CommandBuilder.new 'convert'
      command.push tmp_image.path
      command.push png_image.path
      tmp_image.run command

#     "A0" => [2383.94, 3370.39],
      pdf.start_new_page
      pdf.bounding_box( [0, pdf.cursor], :width => 2384, :height => 3371 ) do
         pdf.image "./tmp/output.png", :fit => [2384, 3371]
      end

      FileUtils.rm_f [ tmp, './tmp/output.djvu', './tmp/output.png' ]
   end

   pdf.render_file "./tmp/#{book}.pdf"
=begin
   outline.define do
   section("Section 1", :destination => 1) do
      page :title => "Page 2", :destination => 2
      page :title => "Page 3", :destination => 3
   end
   section("Section 2", :destination => 4) do
      page :title => "Page 5", :destination => 5
      section("Subsection 2.1", :destination => 6, :closed => true) do
         page :title => "Page 7", :destination => 7
      end
   end
   end
=end

#   `djvm -c './tmp/#{book}.djvu' ./tmp/djvu/*.djvu`
end


