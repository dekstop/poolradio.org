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

  :url => 'http://ws.audioscrobbler.com/1.0/tag/toptags.xml',
  
  # min number of elements required per tag
  :min_tag_count => 50,
  
  :username => 'poolradio',
  
  :source_id => 4
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


# ========
# = main =
# ========

# connect
DB = Sequel.connect(
  @prefs[:db][:url], 
  :logger => nil #Logger.new('db.log')
)

puts "#{@prefs[:url]} ..."
data = http_get(@prefs[:url])
#data = File.read('../data/toptags.xml')

# iterate
num_events_created = 0
doc = REXML::Document.new(data)
doc.elements.each('toptags/tag') do |item|
  tagname = item.attributes['name']
  link = item.attributes['url']
  count = item.attributes['count'].to_i
  
  if (count >= @prefs[:min_tag_count])
    radiourl = 'lastfm://globaltags/%s' % [CGI.escape(tagname)]
    title = '%s' % [tagname]
    message = 'Global Tag Radio'
    
    # make sure we don't create dupes
    existing_events = DB[:events].filter({ 
      :source_id => @prefs[:source_id],
      :radiourl => radiourl,
      :username => @prefs[:username]
    })

    if (existing_events.size > 0)
      puts "Skipping: entry for #{radiourl} by user #{@prefs[:username]} already exists"
    else
      # update
      begin
        puts "Found new tag: #{tagname}"
        DB[:events] << {
          :source_id => @prefs[:source_id],
          :username => @prefs[:username],
          :link => link,
          :radiourl => radiourl,
          :title => title,
          :message => message
        }
        num_events_created += 1
      rescue Mysql::Error
        puts "Mysql error: #{$!.message}"
        require 'pp'
        pp $!
        exit 1
      rescue Exception
        require 'pp'
        pp $!
      end
    end
  end
end

puts "Inserted #{num_events_created} new events"

