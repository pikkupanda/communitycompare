require 'yaml'
require 'stopwords'
require 'table_print'

# Takes: "My name is Andy.""
# Return: ["My", "name", "is", "Andy"]
def tokenize(text)
    text.split(" ")
end

def remove_stopwords(tokens)
  stopwords = Stopwords::Snowball::Filter.new "en"
  # haha apparantly since .stopwords is only readable we cant
  # "=" on it, but push still works.
  stopwords.stopwords.push 'so'
  stopwords.stopwords.push 'actually'
  stopwords.stopwords.push 'really'
  stopwords.stopwords.push 'can'
  stopwords.stopwords.push 'just'
  # this could be solved with sanitizing
  stopwords.stopwords.push 'we&#39;re'
  stopwords.stopwords.push 'don&#39;t'
  stopwords.stopwords.push 'it&#39;s'
  stopwords.stopwords.push 'that&#39;s'
  stopwords.filter(tokens)
end

# Takes: "0:16My name is Andy."
# Returns: "my name is andy."
def sanitize(text)
  new_text = ""
  text.each_line do |line|
    line = line[(line.index(':')) + 3..-1]
    new_text += line
  end
  new_text.downcase
end

def promille(word, tokens)
  tokens.count(word).to_f / tokens.length * 1000
end

def most_often_word(tokens)
  tokens_times = {}
  tokens.each do |token|
    if not tokens_times[token] then 
      tokens_times[token] = 0
    end
    tokens_times[token] += 1
  end
  ordered = tokens_times.sort_by {|_, value| -value }
  ordered.first[0]
end

# takes a word and returns array with hashes with the counts
# @word String
def word_count(word)
  talks = []
  
  Dir.glob("./data/*/*.yml") do |file|
    talk = {}
    talk[:community] = file.split('/')[-2]
    
    data = YAML.load_file(file)
    tokens = remove_stopwords(tokenize(sanitize(data['text'])))
    
    talk[:speaker] = data['speaker']
    talk[:count] = promille(word, tokens)
    talk[:url] = data['source']
    talk["Most often word"] = most_often_word(tokens);
    
    talks.push talk
  end
  
  talks
end

# displays the means for each community of the given data
def community_means(data)
  data_community = {}
  data_com_count = {}

  data.each { |row|
    if not data_community[row[:community]] then data_community[row[:community]] = 0 end
    if not data_com_count[row[:community]] then data_com_count[row[:community]] = 0 end
    data_community[row[:community]] += row[:count] 
    data_com_count[row[:community]] += 1
  }

  puts 'means --------------------'
  data_community.each { |community, count|
    data_community[community] = count.to_f/data_com_count[community]
    puts community + " : " + data_community[community].to_s
  }
  puts '--------------------------'
end



ARGV.each { |word|
    puts "------------ analizing word: #{word.upcase} -----------------"
    data = word_count(word)

    community_means(data)
    
    tp data
}
