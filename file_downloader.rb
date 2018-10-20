require 'open-uri'
require_relative 'file_helper_methods'

include FileHelperMethods

class FileDownloader
  def self.get_current_nfl_standings_html
    file_data = open("https://www.pro-football-reference.com/").read
    file = File.open(current_file_path, 'w')
      file.puts(file_data)
    file.close
  end
end