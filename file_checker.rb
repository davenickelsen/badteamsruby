require_relative 'file_helper_methods'

include FileHelperMethods

class FileChecker
  def self.has_latest_standings?
    File.exists?(current_file_path)
  end
end