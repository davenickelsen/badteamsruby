require 'sinatra'
require_relative 'html_resolver'
require_relative 'standings_resolver'

class App < Sinatra::Application
  set :app_file, __FILE__
  set :public_folder, 'public'
    set :host_authorization, permitted_hosts: [
    "fridgefootball.com",
    "www.fridgefootball.com",
    "badteams.fridgefootball.com",
    "localhost",
    "127.0.0.1",
    "[::1]"
]

  get '/' do
    today = Date.today
    year = today.month < 6 ? today.year - 1 : today.year
    standings_resolver = StandingsResolver.new(year)
    standings = standings_resolver.resolve
    html_resolver = HtmlResolver.new
    content_type "text/html"
    content = html_resolver.resolve(standings)
    content
  end

end

App.start!