require 'requests/sugar'
require 'logger'

$logger = Logger.new(STDERR)
$logger.level = Logger::INFO

def env(var)
  ENV[var.to_s] || raise("Please define #{var.to_s} in environment")
end

def get(endpoint)
  JSON.parse(
    Requests.get(
      "https://docsapi.helpscout.net/v1/#{endpoint}".tap {|uri| $logger.info("fetching #{uri}") },
      auth: [ env(:HELPSCOUT_DOCS_KEY), 'X' ]
    ).body.tap { |j| $logger.debug("response: #{j}") }
  )
end

def get_items(endpoint)
  item_name = endpoint.split('/').last
  items = []
  page = 1
  loop do
    r = get(endpoint + "?page=#{page}")[item_name]
    items += r['items']

    page += 1
    break if r['pages'] == 1 or page > r['pages']
  end
  items
end

get_items('collections')
.each do |c|
  filename = "backups/#{c['slug']}.json"
  c['articles'] = get_items("collections/#{c['id']}/articles").tap { |as| puts as.size }
  .map { |a| get("articles/#{a['id']}")['article'] }
  File.write(filename, JSON.pretty_generate(c))
end
