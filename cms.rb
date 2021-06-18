require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

root = File.expand_path("..", __FILE__)

get '/' do
  @files = Dir.glob(root + '/data/*').map { |path| File.basename(path) }

  erb :index
end

# Open a document as text file

get '/:file_name' do
  file_path = root + '/data/' + params[:file_name]
  headers["Content-Type"] = "text/plain"
  File.readlines(file_path)
end



