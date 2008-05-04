#
# martind 2008-05-03, 14:28:26
# 

require 'rubygems'
require 'sequel'
require 'logger'

require 'net/http'
require 'rexml/document'
require 'date'
require 'time'
require 'cgi'
require 'uri'

$: << File.expand_path(File.dirname($0))
require 'global_prefs'


# =========
# = prefs =
# =========

@prefs = GLOBAL_PREFS.merge({
  # pursue redirect headers?
  :handle_redirects => true,

  :url => 'http://ws.audioscrobbler.com/1.0/user/poolradio/manualrecs.rss',
  
  :message_pattern => /^(.*?) says: "(.*)"$/,
  
  :source_id => 2
})

# ===========
# = helpers =
# ===========

def http_get(url)
  uri = URI.parse(url)
  remote_domain, remote_path = uri.host, uri.request_uri
  data = Net::HTTP.start(remote_domain) do |http|
    req = Net::HTTP::Get.new(remote_path, {'User-Agent' => @prefs[:useragent]})
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

# strips protocol, host, and query string
def extract_request_path(url)
  URI.split(url)[5]
end

# ...
def build_radiourl_from_lastfm_listen_url(url)
  path = extract_request_path(url)
  matches = path.match(/^\/listen\/(.+)$/)
  if (matches)
    "lastfm://#{matches.captures.first}"
  end
  nil
end


# ========
# = main =
# ========

# connect
DB = Sequel.connect(
  @prefs[:db][:url], 
  :logger => nil #Logger.new('db.log')
)
# fetch
data = http_get(@prefs[:url])
#data = File.read('../data/martind.xml')

# iterate
doc = REXML::Document.new(data)
count = 0
doc.elements.each('rss/channel/item') do |item|
  title = item.elements['title'].text
  link = item.elements['link'].text
  description = CGI.unescapeHTML(item.elements['description'].text)
  
  matches = description.match(@prefs[:message_pattern])
  if (matches!=nil && matches.captures.size==2)
    username = matches.captures[0]
    description = matches.captures[1]
  end
  
  radiourl = build_radiourl_from_lastfm_listen_url(link)
  
  if (radiourl.nil?)
    puts "Can't convert to radio URL: #{link}"
  else
    # make sure we don't create dupes
    existing_events = DB[:events].filter({ 
      :source_id => @prefs[:source_id],
      :radiourl => radiourl,
      :username => username
    })
    
    if (existing_events.size > 0)
      puts "Skipping: entry for #{radiourl} by user #{username} already exists"
    else
      # update
      begin
        DB[:events] << {
          :source_id => @prefs[:source_id],
          :username => username,
          :link => link,
          :radiourl => radiourl,
          :title => title,
          :message => description
        }
        count += 1
      rescue Mysql::Error
        puts "Can't insert row: #{$!.message}"
      rescue Exception
        require 'pp'
        pp $!
      end
    end
  end
  $stdout.flush
end

puts "Inserted #{count} new events"
