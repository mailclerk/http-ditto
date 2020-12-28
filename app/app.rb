require "sinatra"

##########################
## Application State #####
##########################

store = []
counter = 0

# Set to be very very high if you don't want this to come into effect
MAX_STORE_COUNT = ENV["MAX_STORE_COUNT"] ? ENV["MAX_STORE_COUNT"].to_i : 3

##########################
## Helper Methods ########
##########################

def restful_verbs(url, &block)
  get(url, &block)
  post(url, &block)
  patch(url, &block)
  put(url, &block)
  delete(url, &block)
end

##########################
## Routes ################
##########################

get "/" do
  "HTTP Polly Parrot!"
end

restful_verbs "/store" do
  # Only works for JSON data and query params right now
  data = {
    "received_at" => Time.now.to_f,
    "received_index" => counter,
    "method" => request.request_method,
    "query" => params
  }
  
  if request.body
    body = request.body.read
    begin
      data["json"] = JSON.parse(body)
    rescue JSON::ParserError
      data["body"] = body
    end
  end
  
  counter += 1
  
  store << data
  if store.length > MAX_STORE_COUNT
    store.shift
  end
  
  content_type :json
  return data.to_json
end

get "/fetch" do
  content_type :json
  return store.to_json
end

get "/fetch/latest" do
  content_type :json
  return store.last.to_json
end

get "/fetch/search" do
  path = params[:path]     # E.g. "options.from.address"
  target = params[:target] # E.g. "sales@mailclerk.app"
  if path.nil? || target.nil?
    error 400 do
      return "Missing path or target", 400
    end
  end
  parts = path.split(".")
  matches = []
  
  store.each do |item|
    if parts.length == 1 && item["query"][parts[0]] == target
      matches << item

    elsif item["json"]
      stage = item["json"]

      # For each part of the path, dig into the json object
      parts.each do |part|
        break if stage.nil? || !stage.is_a?(Hash)
        stage = stage[part]
      end

      if stage && stage.to_s == target.to_s
        matches << item
      end
    end
  end
  
  content_type :json
  return matches.to_json
end