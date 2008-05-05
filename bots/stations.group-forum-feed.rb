#
# martind 2008-05-03, 14:28:26
# 

require 'rubygems'
require 'sequel'
require 'logger'
require 'hpricot'

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

  :url => 'http://ws.audioscrobbler.com/1.0/forum/%d/posts.rss',
  :sleep => 3,
  
  # min number of elements required per tag
  :min_tag_count => 50,
  
  :source_id => 5
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

# takes a Last.fm page URL, transforms it into a radio URL. Might return nil
def build_radiourl_from_link(link)
  return nil if link.nil?
  if (matches = link.match(/http:\/\/.*\/user\/([^\/]+)\/tags\/([^\/]+)/))
    'lastfm://usertags/%s/%s' % [
      CGI.escape(matches.captures[0]), 
      CGI.escape(matches.captures[1])]
  elsif (matches = link.match(/http:\/\/.*\/tag\/([^\/]+)/))
    'lastfm://globaltags/%s' % [
      CGI.escape(matches.captures[0])]
  else 
    nil
  end
end

def extract_username_from_post(node)
  (node/"ul[@class='commentUserDetails']/li[@class='userName]/span[1]").text.gsub(/<\/?[^>]*>/, "")
end

def extract_permalink_from_post(node)
  link = (node/"a[@class='permalinkbutton']").first['href']
  if (link.match(/^http:\/\/.*/))
    link
  else
    "http://www.last.fm#{link}"
  end
end

# returns a list of records [{:radiourl => '...', :title => '...'}, ...]
def extract_stations_from_post(node)
  links = (node/"div[@class='messageContent]/a")
  links.select do |link|
    link.bogusetag? ? false : true
  end.map do |link|
    {
      :href => link['href'],
      :text => link.inner_html.gsub(/<\/?[^>]*>/, "")
    }
  end.map do |link|
    {
      :radiourl => build_radiourl_from_link(link[:href]),
      :title => link[:text]
    }
  end.select do |link|
    link[:radiourl].nil? ? false : true
  end
end

def extract_posts_from_page(doc)
  (doc/"li[@class='comment']")
end

# ========
# = main =
# ========

# connect
DB = Sequel.connect(
  @prefs[:db][:url], 
  :logger => nil #Logger.new('db.log')
)

puts 'Loading forum IDs...'
forums = DB.from(:group_forums)

forum_ids = forums.all.map { |u| u[:forum_id] }
if (forum_ids.size==0)
  puts "No forums in queue"
  exit 1
end

puts "#{forum_ids.size} forums in queue"

forum_ids.sort_by { rand }.each do |forum_id|
  feed_url = @prefs[:url] % [forum_id]
  puts "#{feed_url} ..."
  data = http_get(feed_url)
  #data = File.read('../data/forum-posts.xml')

  # iterate
  doc = REXML::Document.new(data)
  doc.elements.each('rss/channel/item') do |item|
    thread_title = item.elements['title'].text
    thread_link = item.elements['link'].text
    
    sleep @prefs[:sleep]

    # scrape forum pages
    num_stations_skipped = 0
    num_events_created = 0

    puts "#{thread_link} ..."
    thread_data = http_get(thread_link)
    #thread_data = File.read('../data/group-forum-usertags.html')
    thread_doc = Hpricot.parse(thread_data)
    
    nodes = extract_posts_from_page(thread_doc)
    nodes.each do |node|
      username = extract_username_from_post(node)
      stations = extract_stations_from_post(node)
      permalink = extract_permalink_from_post(node)

      stations.each do |station|
        radiourl = station[:radiourl]
        title = station[:title]
        
        existing_events = DB[:events].filter({ 
          :source_id => @prefs[:source_id],
          :radiourl => radiourl,
          :username => username
        })

        if (existing_events.size > 0)
          #puts "Skipping: entry for #{radiourl} by user #{username} already exists"
          num_stations_skipped += 1
        else
          # update
          begin
            DB[:events] << {
              :source_id => @prefs[:source_id],
              :username => username,
              :link => permalink,
              :radiourl => radiourl,
              :title => title,
              :message => "Forum Thread: #{thread_title}"
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
    puts "Inserted #{num_events_created} new events, skipped #{num_stations_skipped} known stations"
  end
  
  $stdout.flush
end

