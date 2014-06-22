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
# media$title":{"$t":"Ruby Conf 2013 - Effective Debugging by Jonathan Wallace"
def get_title(yt_title)
  yt_title[16..-1].split(" by ")[0]
end

def get_speaker(yt_title, yt_desc)
  if(yt_desc.start_with?("By")) then
    yt_desc[3..-1].split("\n\n")[0]
  else
    yt_title.split(" by ").last
  end
end
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
  video_title = video['title']['$t']
  video_desc = video['content']['$t']
  
  puts "Download #{video_id}"
  puts video_title
  
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
  talk['speaker'] = get_speaker(video_title, video_desc)
  talk['title'] = get_title(video_title) 
  
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
