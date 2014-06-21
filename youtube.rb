require 'json'
require 'net/http'
require 'pp'
require 'yaml'
require 'xmlsimple'

## Configure this ##
playlist_id = "E7tQUdRKcyb5I7Bk1POYW4udtHMUMkK7"
community = "ruby"
conference = "RubyConf"
year = 2013

####################

playlist_url = "http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?alt=json"

resp = Net::HTTP.get_response(URI.parse(playlist_url))
playlist_data = JSON.parse(resp.body)

playlist = playlist_data['feed']['entry']

talks = []

playlist.each do |video|
  talk = {}
  
  video_url = video['link'].find{|e| e['rel'] == 'related'}['href']
  video_id = video_url.split('/').last
  
  puts "Download #{video_id}"
  
  caption_url = "http://www.youtube.com/api/timedtext?lang=en&v=#{video_id}"
  resp = Net::HTTP.get_response(URI.parse(caption_url))
  if resp.body == "" then
    next 
  end
  lines = XmlSimple::xml_in(resp.body)['text']
  talk['conference'] = conference
  talk['year'] = year
  talk['source'] = "https://www.youtube.com/watch?v=#{video_id}"
  talk['automatic'] = false
  talk['duration'] = 0 # TODO
  talk['speaker'] = "" # TODO
  talk['title'] = "" # TODO
  
  talk['text'] = ""
  
  lines.each do |line|
    t = line['start'].to_i
    mm, ss = t.divmod(60)
    #hh, mm = mm.divmod(60)
    line_text = line['content'].gsub("\n", "")
    talk['text'] += "#{mm}:#{ss}#{line_text}\n"
  end
  
  
  talks.push(talk)
end

talks.each_with_index do |talk, index|
  
  talk_path = "data/#{community}/#{conference.downcase}-#{year}-#{index + 1}.yml"
  puts "Write #{talk_path}"
  f = File.new(talk_path, "w")
  f.write(talk.to_yaml)
  f.close
  
end
