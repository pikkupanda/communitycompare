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
    
    talks.push talk
  end
  
  talks
end

if ARGV.length == 0 then ARGV[0] = 'fun' end

ARGV.each { |word|
    puts "------------ analizing word: #{word.upcase} -----------------"
    data = word_count(word)

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

    tp data
}
