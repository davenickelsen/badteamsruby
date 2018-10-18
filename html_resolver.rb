require 'erb'

class HtmlResolver

  def resolve(standings)
    standings_file = File.open('./html/standings.erb')
    standings_template = standings_file.read
    standings_file.close
    processor = ERB.new(standings_template, 0, "%<>")
    processor.result(binding)
  end
end