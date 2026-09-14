require 'open-uri'
require 'nokogiri'
require_relative 'file_helper_methods'

include FileHelperMethods

class FileDownloader
  STANDINGS_URL = 'https://www.nfl.com/standings/'

  # NFL.com uses some abbreviations that differ from Pro-Football-Reference.
  # Map them so the existing standings resolver can match the config files.
  ABBREVIATION_MAP = {
    'AZ'  => 'ARI',
    'LA'  => 'LAR',
    'NE'  => 'NWE',
    'GB'  => 'GNB',
    'NO'  => 'NOR',
    'TB'  => 'TAM',
    'KC'  => 'KAN',
    'LV'  => 'LVR',
    'SF'  => 'SFO'
  }.freeze

  def self.get_current_nfl_standings_html
    html = URI.open(STANDINGS_URL, 'User-Agent' => user_agent).read
    build_standings_html(Nokogiri::HTML(html))
  end

  def self.build_standings_html(document)
    afc_rows = []
    nfc_rows = []

    document.css('table.d3-o-standings--detailed').each do |table|
      header_text = table.at_css('thead th')&.text.to_s
      conference = conference_from_header(header_text)
      next unless conference

      table.css('tbody tr').each do |row|
        tds = row.css('td')
        next if tds.size < 4

        team_abbr = extract_team_abbreviation(row)
        next unless team_abbr

        row_html = build_team_row(team_abbr, tds)
        if conference == 'AFC'
          afc_rows << row_html
        else
          nfc_rows << row_html
        end
      end
    end

    wrap_table('AFC', afc_rows) + wrap_table('NFC', nfc_rows)
  end

  def self.extract_team_abbreviation(row)
    logo_src = row.at_css('img')&.[]('src')
    return unless logo_src

    logo_src[/logos\/(\w+)/, 1]&.upcase
  end

  def self.conference_from_header(header_text)
    return 'AFC' if header_text.start_with?('AFC')
    return 'NFC' if header_text.start_with?('NFC')
  end

  def self.build_team_row(abbreviation, cells)
    team_code = ABBREVIATION_MAP.fetch(abbreviation, abbreviation)
    wins = cells[1].text.strip
    losses = cells[2].text.strip
    ties = cells[3].text.strip

    %(<tr><th scope="row"><a>#{team_code}</a></th><td data-stat="wins">#{wins}</td><td data-stat="losses">#{losses}</td><td data-stat="ties">#{ties}</td></tr>)
  end

  def self.wrap_table(conference, rows)
    %(<div class="table_container" id="div_#{conference}"><table id="#{conference}"><tbody>#{rows.join}</tbody></table></div>)
  end

  def self.user_agent
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
  end
end
