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


# =========
# = prefs =
# =========

@prefs = {
  :user_agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)',
  # pursue redirect headers?
  :handle_redirects => true,
  # sleep between fetches
  :sleep => 1,

  :url => 'http://google.com/search?q=site:wikipedia.org+%s',
  
  :db_url => 'mysql://radiobot:radiobot@localhost/radiobot'
}

# ===========
# = helpers =
# ===========

def http_get(url)
  uri = URI.parse(url)
  remote_domain, remote_path = uri.host, uri.request_uri
  data = Net::HTTP.start(remote_domain) do |http|
    req = Net::HTTP::Get.new(remote_path, {'User-Agent' => @prefs[:user_agent]})
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

def fetch_description(title)
  url = @prefs[:url] % [CGI.escape(title)]
  puts "#{url} ..."
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
  @prefs[:db_url], 
  :logger => nil #Logger.new('db.log')
)
wd = DB.from(:wikipedia_descriptions)

# find events without description
# (limit to newer events so we don't keep re-fecthing the same stuff over and over
# in cases where we always get an empty result)
count = 0
events = DB['SELECT e.id AS id, e.title AS title FROM events e ' +
  'LEFT OUTER JOIN wikipedia_descriptions w ON e.id=w.event_id ' +
  'WHERE w.id IS NULL AND e.created_at>subtime(now(), "48:0:0.0")']

# sequel does lazy loading, yet doesn't seem to support nested calls -> load records manually
events = events.map { |e| e }

if (events.size==0) 
  puts "No events without description, exiting"
  exit
end

events.each do |row|  
  begin
    desc = fetch_description(row[:title])
    unless(desc.nil?)
      require 'pp'
      wd << {
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
  rescue Exception
    require 'pp'
    pp $!
  end
  
  sleep @prefs[:sleep]
end

puts "Found #{count} new descriptions to #{events.size} events"
