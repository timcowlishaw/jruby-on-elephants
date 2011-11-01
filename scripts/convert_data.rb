require 'json'
require 'csv'
DATA_DIR = File.join(File.dirname(__FILE__), "..", "data" )
OUTPUT_FILE = DATA_DIR + "/tweets.csv"

CSV.open(OUTPUT_FILE, "w") do |output_file|
  Dir.new(DATA_DIR).entries.each do |filename|
    next if filename !~ /\.json$/
    json = File.open(File.join(DATA_DIR, filename)) {|f| JSON.parse(f.read)}
    klass = filename =~ /cute_overload/ ? 1 : 0
    (json.is_a?(Array) ? json : json["results"]).each do |result|
      output_file << [result["id"], result["from_user_id"], result["to_user_id"], result["from_user"], result["geo"], result["iso_language_code"], result["created_at"], result["text"], klass]
    end
  end
end

