#
# martind 2008-05-03, 14:28:26
# 

require 'rubygems'
require 'sequel'
require 'logger'
require 'hpricot'

require 'net/http'
require 'cgi'
require 'uri'

$: << File.expand_path(File.dirname($0))
require 'global_prefs'


# =========
# = prefs =
# =========

@prefs = GLOBAL_PREFS.merge({
  # pursue redirect headers?
  :handle_redirects => false,
  # sleep between fetches
  :min_sleep => 5,
  :max_sleep => 30,

  # only select from events that were created in the last n hours
  :subtime_window => '48:0:0.0',
  # don't scrape too much in one go
  :max_google_requests => 500,
  # ...
  :url => 'http://google.com/search?hl=en&q=site:wikipedia.org+%s',
})

# ===========
# = helpers =
# ===========

def http_get(url)
  uri = URI.parse(url)
  remote_domain, remote_path = uri.host, uri.request_uri
  data = Net::HTTP.start(remote_domain) do |http|
    req = Net::HTTP::Get.new(remote_path, {'User-Agent' => @prefs[:cloaking_useragent]})
    response = http.request(req)
    # handle HTTP responses "301 moved permanently", "302 found"
    if @prefs[:handle_redirects]
      return http_get(response['Location']) if response.code =~ /30[12]/
    end
    # exit if request didn't succeed
    raise "HTTP #{response.code}: #{response.message}" unless 
      (response.code =~ /2\d{2}/)
    response.body
  end
end

def extract_title(doc)
  node = (doc/"div[@class='g']/h2[@class='r]/").first
  if (node)
    node.inner_html.gsub(/<\/?[^>]*>/, "")
  else
    nil
  end
end

def extract_link(doc)
  node = (doc/"div[@class='g']/h2[@class='r]/a[@class='l]").first
  if (node)
    node['href']
  else
    nil
  end
end

def extract_description(doc)
  #node = (doc/"div#res"/"div"/"div.g"/"table"/"tr"/"td.j"/"div.std").first
  #node = (doc/"//div[@id='res']/div[1]/div[1]/table/tr/td/div").first
  node = (doc/"div[@class='g']/table/tr/td/div").first
  matches = node.inner_html.match(/^(.*?)<span.*$/)
  if (matches)
    CGI.unescapeHTML(matches.captures.first).gsub(/<\/?[^>]*>/, "")
  else 
    nil
  end
end

def fetch_description(url)
  data = http_get(url)
  #data = File.read('../data/google-wikipedia-search.html')
  doc = Hpricot.parse(data)

  result = {
    :title => extract_title(doc),
    :link => extract_link(doc),
    :description => extract_description(doc)
  }
  result
end

# ========
# = main =
# ========

# connect
DB = Sequel.connect(
  @prefs[:db][:url], 
  :logger => nil #Logger.new('db.log')
)

# find events without description
# (limit to newer events so we don't keep re-fecthing the same stuff over and over
# in cases where we always get an empty result)
count = 0
query = ('SELECT e.id AS id, e.title AS title FROM events e ' +
  'LEFT OUTER JOIN wikipedia_descriptions w ON e.id=w.event_id ' +
  'WHERE w.id IS NULL AND e.created_at>subtime(now(), "%s") ' +
  'ORDER BY RAND() LIMIT %d') % [@prefs[:subtime_window], @prefs[:max_google_requests]]

puts 'Loading events...'
events = DB[query]

# sequel does lazy loading, yet doesn't seem to support nested calls -> load records manually
events = events.map { |e| e }

if (events.size==0) 
  puts "No events without description, exiting"
  exit
end

puts "#{events.size} events in queue"

events.each do |row|  
  begin
    url = @prefs[:url] % [CGI.escape(row[:title])]
    puts "#{url} ..."
    desc = fetch_description(url)
    
    if(desc.nil? || desc[:description].nil?)
      puts 'Could not extract a description from that page'
    else
      DB[:wikipedia_descriptions] << {
        :event_id => row[:id],
        :title => desc[:title],
        :link => desc[:link],
        :description => desc[:description],
      }
      count += 1
    end
  rescue Mysql::Error
    puts "Can't insert row: #{$!.message}"
    require 'pp'
    pp $!
  rescue RuntimeError
    if ($!.message =~ /^HTTP 302.*/)
      puts "#{$!.message} -- looks like we're being throttled"
      exit 1
    end
  rescue Exception
    require 'pp'
    pp $!
  end
  $stdout.flush
  
  n = rand(@prefs[:max_sleep] - @prefs[:min_sleep]) + @prefs[:min_sleep]
  puts "Sleeping for #{n} seconds..."
  sleep n
end

puts "Found #{count} new descriptions for #{events.size} events"
