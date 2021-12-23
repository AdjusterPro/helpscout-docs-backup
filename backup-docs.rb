require 'requests/sugar'
require 'logger'

load 'lib/tools.rb'

$logger = Logger.new(STDERR)
$logger.level = Logger::INFO

get_items('collections')
.each do |c|
  filename = "backups/#{c['slug']}.json"
  c['articles'] = get_items("collections/#{c['id']}/articles")
  .tap { |articles| $logger.info("#{c['name']} has #{articles.size} articles") }
  .map { |a| get("articles/#{a['id']}")['article'] }
  File.write(filename, JSON.pretty_generate(c))
end
