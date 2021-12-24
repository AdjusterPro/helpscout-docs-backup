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
  page = 1
  items = []
  loop do
    r = get(endpoint + "?page=#{page}")[item_name]
    items += r['items']

    page += 1
    break items if page > r['pages']
  end
end

