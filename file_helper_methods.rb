module FileHelperMethods

  def current_file_path
    File.join(File.dirname(__FILE__), "html", "#{Date.today.strftime('%m-%d-%Y')}.html")
  end

  def clean_html
    files = Dir.glob("./html/*.html")
    files.each do |file|
      File.delete(file)
    end
  end
end