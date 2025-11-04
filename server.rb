require "sinatra"
require "sinatra/cross_origin"
require "json"
require "apkg_to_csv"
require "fileutils"

configure do
  enable :cross_origin
  set :bind, "0.0.0.0"
  set :port, ENV["PORT"] || 4567
end

# Register cross_origin properly
register Sinatra::CrossOrigin

# Allow all origins
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

# Preflight OPTIONS requests
options "*" do
  response.headers["Allow"] = "HEAD,GET,POST,OPTIONS"]
  response.headers["Access-Control-Allow-Headers"] = "Content-Type, Accept, Authorization, Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

post "/parse" do
  cross_origin # Enable CORS for this route

  unless params[:file]
    halt 400, { error: "No file uploaded" }.to_json
  end

  FileUtils.mkdir_p("./tmp")
  tempfile = params[:file][:tempfile]
  output_path = "./tmp/deck_#{Time.now.to_i}.csv"

  system("apkg-to-csv #{tempfile.path} > #{output_path}")

  unless File.exist?(output_path)
    halt 500, { error: "Conversion failed" }.to_json
  end

  content_type "text/csv"
  send_file output_path, filename: "deck.csv"
end
