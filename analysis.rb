require 'yaml'

# Takes: "My name is Andy.""
# Return: ["My", "name", "is", "Andy"]
def tokenize(text)
    text.split(" ");
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

def percentage(word, tokens)
  tokens.count(word).to_f / tokens.length * 100
end

Dir.glob("./data/ruby/*.yml") do |file|
  talk = YAML.load_file(file)
  tokens = tokenize(sanitize(talk['text']))
  print talk['speaker']
  print "\t\t"
  print percentage("fun", tokens)
  print "\n"
end
