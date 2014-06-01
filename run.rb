require 'sinatra'

set :bind, '0.0.0.0'
set :port, '8000'
set :protection, :except => :frame_options

after do
  headers({ 'X-Frame-Options' => 'ALLOW-FROM *' })
end


get "/" do
  send_file "index.html"
end

get "/*" do |file|
  send_file file
end
