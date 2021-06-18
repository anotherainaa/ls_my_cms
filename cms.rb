require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

def render_markdown(text)
  markdown =  Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  if File.extname(path) == ".md"
    render_markdown(content)
  else
    headers["Content-Type"] = "text/plain"
    content
  end
end

get '/' do
  @files = Dir.glob(root + '/data/*').map { |path| File.basename(path) }

  erb :index
end

# Open a document as text file

get '/:file_name' do
  file_path = root + '/data/' + params[:file_name]
  if File.exist? file_path
    load_file_content(file_path)
  else
    session[:error] = "#{params[:file_name]} does not exist."
    redirect '/'
  end
end

=begin
Problem:
- [x] Render Markdown files as HTML files
- [x]unlike the text files that we have?

Notes:
- Use redcarpet to use markdown - it's a gem to render Markdown into HTML
- How to test this?
  - check for HTML tags? can use include to do this on a header or something
- does that mean, I need to figure out if a file is a markdown,
  - separately to txt files.


Todos:
- [x] render markdowns as HTML using redcarpet
- [x] add a test fot testing markdown
- [ ] refactor code with helper methods
=end
