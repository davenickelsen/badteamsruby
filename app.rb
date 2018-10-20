require 'sinatra'
require_relative 'html_resolver'
require_relative 'standings_resolver'

Sinatra::Base.set :app_file, __FILE__
Sinatra::Base.set :public_folder, File.dirname(__FILE__)

Sinatra::Base.get '/' do
  today = Date.today
  year = today.month < 6 ? today.year - 1 : today.year
  standings_resolver = StandingsResolver.new(year)
  standings = standings_resolver.resolve
  html_resolver = HtmlResolver.new
  content_type "text/html"
  content = html_resolver.resolve(standings)
  content
end

port = 4567 if port.nil?

Sinatra::Base.start!({:bind => '0.0.0.0', :port => port})