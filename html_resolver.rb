require 'erb'

class HtmlResolver

  def resolve(standings)
    standings_file = File.open('./html/standings.erb')
    standings_template = standings_file.read
    standings_file.close
    processor = ERB.new(standings_template, trim_mode: "%<>")
    processor.result(binding)
  end
end