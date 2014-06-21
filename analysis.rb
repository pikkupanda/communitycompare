require 'yaml'
require 'stopwords'

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

Dir.glob("./data/ruby/*.yml") do |file|
  talk = YAML.load_file(file)
  tokens = remove_stopwords(tokenize(sanitize(talk['text'])))
  print talk['speaker']
  print "\t\t"
  print promille("fun", tokens)
  print "\n"
end
