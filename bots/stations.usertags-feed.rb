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

  :url => 'http://ws.audioscrobbler.com/1.0/user/%s/tags.xml',
  :sleep => 1,
  
  # min number of elements required per tag
  :min_tag_count => 50,
  
  :source_id => 3
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

puts 'Loading usernames...'
usertags_users = DB.from(:usertags_users)

users = usertags_users.all.map { |u| u[:username] }
if (users.size==0)
  puts "No users in queue"
  exit 1
end

puts "#{users.size} users in queue"

users.sort_by { rand }.each do |username|
  feed_url = @prefs[:url] % [username]
  puts "#{feed_url} ..."
  data = http_get(feed_url)
  #data = File.read('../data/usertags-jirkanne.xml')

  # iterate
  count = 0
  doc = REXML::Document.new(data)
  doc.elements.each('toptags/tag') do |item|
    tagname = item.elements['name'].text
    count = item.elements['count'].text.to_i
    if (count >= @prefs[:min_tag_count])
      link = 'http://last.fm/user/%s/tags/%s' % [CGI.escape(username), CGI.escape(tagname)]
      radiourl = 'lastfm://usertags/%s' % [CGI.escape(tagname)]
      title = '%s' % [tagname]
      message = 'User Tag Radio'
      
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
            :message => message
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
  end
  
  sleep @prefs[:sleep]
  
  puts "Inserted #{count} new events"
  $stdout.flush
end

