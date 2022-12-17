require 'open-uri'
require_relative 'file_helper_methods'

include FileHelperMethods

class FileDownloader
  def self.get_current_nfl_standings_html
    file_data = URI.open("https://www.pro-football-reference.com/").read
    afc = self.parse_section(file_data, /\<div.*id=\"div_AFC\">/)
    nfc = self.parse_section(file_data, /\<div.*id=\"div_NFC\">/)
    file = File.open(current_file_path, 'w')
    file.puts(file_data)
    file.puts(afc)
    file.puts(nfc)
    file.close
  end

  def self.parse_section(file_data, start_regex)
    critical_section_start_position = file_data.match(start_regex).begin(0)
    critical_section_start = file_data[critical_section_start_position..]
    end_regex = /\<\/div\>/
    critical_section_end_position = critical_section_start.match(end_regex).end(0)
    critical_section = critical_section_start[0..critical_section_end_position]
  end
end