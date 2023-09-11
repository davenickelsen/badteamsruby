require 'nokogiri'
require 'fig_newton'
require_relative 'file_checker'
require_relative 'file_downloader'
include FileHelperMethods

class StandingsResolver

  attr_accessor :year

  def initialize(year)
    @year = year
  end

  def resolve
    nfl_standings = resolve_nfl_standings
    FigNewton.load "#{@year}.yml"
    standings = FigNewton.owners.map do |owner_info|
      selected_teams = owner_info["owner"]["teams"].map do |team|
        nfl_standings.find {|s| s[:team] == team}
      end
      owner_totals = selected_teams.reduce({:owner => owner_info["owner"]["name"], :wins => 0, :losses => 0, :ties => 0, :games => 0}) do |memo, team|
        memo[:wins] += team[:wins].to_i
        memo[:losses] += team[:losses].to_i
        memo[:ties] += team[:ties].to_i
        memo[:games] += memo[:wins].to_i + memo[:losses].to_i + memo[:ties].to_i
        memo
      end
      owner_totals[:teams] = selected_teams.sort{|a, b| a[:wins] <=> b[:wins]}
      if owner_totals[:ties] > 0
        owner_totals[:wins] += 0.5 * owner_totals[:ties]
        owner_totals[:losses] += 0.5 * owner_totals[:ties]
      end
      owner_totals[:pct] = owner_totals[:wins].to_f / owner_totals[:games].to_f
      owner_totals[:wins]
      owner_totals
    end
    standings.sort!{|a,b| a[:pct] <=> b[:pct]}
    standings
  end

  private

  def resolve_nfl_standings
    if !FileChecker.has_latest_standings?
      clean_html
      FileDownloader.get_current_nfl_standings_html
    end
    file = File.open(current_file_path)
    data = file.read
    file.close
    document = Nokogiri::HTML(data)
    afc_rows = document.css("#AFC tr")
    nfc_rows = document.css("#NFC tr")
    rows = [afc_rows, nfc_rows].flatten
    data_set = rows.reduce([]) do |memo, tr|
      th = tr.css("th[scope='row']")
      if !th.nil?
        anchor = th.css('a')
        wins = tr.css("td[data-stat='wins']").text
        losses = tr.css("td[data-stat='losses']").text
        ties = tr.css("td[data-stat='ties']").text
        memo.push({:team => anchor.text, :wins => wins, :losses => losses, :ties => ties})
      end
      memo
    end
    data_set.reject!{|row| row[:team] == ''}
    data_set
  end
end