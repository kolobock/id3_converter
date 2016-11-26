require 'id3tag'
require 'taglib'

module Id3Converter
  # overrides ID3Tag source_encoding for V2
  ID3Tag::Frames::V2::TextFrame::ENCODING_MAP[0b0] = Encoding::CP1251

  # overrides ID3Tag source_encoding for V1
  class ID3Tag::Frames::V1::TextFrame
    private
      def source_encoding
        Encoding::CP1251
      end
  end

  # attributes mapping from taglib->id3tag (writter->reader)
  V1_ATTRS = [:album, :artist, {comment: :comments}, :title]
  V2_ATTRS = %i(TALB TPE1 COMM TIT2 TCOM)

  def convert_dir(fdir, debug: true)
    Dir.glob("#{fdir}/*.mp3").each do |fl|
      update_tag_for fl, debug: debug
    end
  end
  module_function :convert_dir

  def update_tag_for(f, debug: true)
    puts '-----------------------------------------------------------'
    puts f
    rt = ID3Tag.read(File.open(f, 'rb'))
    TagLib::MPEG::File.open(f) do |file|
      if debug
        puts '****BEFORE****'
        show_debug_info file
      end

      update_v1_tag file.id3v1_tag, rt
      update_v2_tag file.id3v2_tag, rt

      if debug
        puts '****AFTER****'
        show_debug_info file
      else
        file.save TagLib::MPEG::File::AllTags, false # do not strip other tags. save any!
      end
    end
  end
  module_function :update_tag_for

  private

  def update_v1_tag(v1, rt)
    V1_ATTRS.map do |attr|
      a1 = a2 = attr
      if attr.is_a? Hash
        a1 = attr.keys.first
        a2 = attr.values.first
      end

      fcontent = get_frame_content(rt, a2)
      next if fcontent.nil?

      v1.public_send "#{a1}=", fcontent
    end
  end

  def update_v2_tag(v2, rt)
    V2_ATTRS.map do |attr|
      fcontent = get_frame_content(rt, attr)
      next if fcontent.nil?

      t = v2.frame_list("#{attr}").first
      t.text = fcontent
    end
  end

  def get_frame_content(rt, attr)
    fr = rt.get_frame(attr)
    return if fr.nil?

    fc = fr.content
    return if fc.empty?

    fc
  end
  module_function :update_v1_tag, :update_v2_tag, :get_frame_content

  def show_debug_info(file)
    v1 = file.id3v1_tag
    V1_ATTRS.each do |attr|
      a = attr.is_a?(Hash) ? attr.keys.first : attr
      puts "#{a}: #{v1.public_send a}"
    end

    v2 = file.id3v2_tag
    V2_ATTRS.each do |attr|
      puts "#{attr}: #{v2.frame_list("#{attr}").map(&:to_s).join(', ')}"
    end
    puts
  end
  module_function :show_debug_info

  puts
  puts "*Example:"
  puts 'dir = "/Volumes/Music/MySongs"'
  puts 'Id3Converter.convert_dir dir #in case to debug: DO NOT save files!'
  puts 'Id3Converter.convert_dir dir, debug: false #in case to DO SAVE files!'
  puts '*'
end
