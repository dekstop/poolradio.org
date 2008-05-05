#
# martind 2008-05-05, 21:01:18
# 

require 'rubygems'
require 'sequel'
require 'logger'

$: << File.expand_path(File.dirname($0))
require 'global_prefs'


# =========
# = prefs =
# =========

@prefs = GLOBAL_PREFS.merge({
  # minimum number of known stations for a user to become auto-added
  :min_station_threshold => 3
})


# ========
# = main =
# ========

# connect
DB = Sequel.connect(
  @prefs[:db][:url], 
  :logger => nil #Logger.new('db.log')
)

# extract all usernames from known usertag stations who aren't yet in the usertags
# list, limit to users above a threshold of stations
query = (
  'SELECT t.username, t.total FROM (' +
    'SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(radiourl, "/", 4), "/", -1) AS username, ' +
    'COUNT(*) AS total FROM events ' +
    'WHERE radiourl LIKE "%%/usertags/%%" ' +
    'GROUP BY username ' +
    'HAVING TOTAL>=%d' +
  ') t ' +
  'LEFT OUTER JOIN usertags_users u ON t.username=u.username WHERE u.id IS NULL'
) % [@prefs[:min_station_threshold]]

puts 'Fetching new usernames from usertags stations...'
users = DB[query]

# sequel does lazy loading, yet doesn't seem to support nested calls -> load records manually
users = users.map { |e| e }

if (users.size==0) 
  puts "No new users found."
  exit
end

puts "#{users.size} new users found"

users.each do |row|
  puts "#{row[:username]} (#{row[:total]} stations)"
  DB[:usertags_users] << {
    :username => row[:username],
    :description => 'Auto-added from usertag station URLs'
  }
  $stdout.flush
end

