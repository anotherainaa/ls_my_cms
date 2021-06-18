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
Problem: Editing Dcoument Content
- Allow users to modify the content stored in the CMS

Questions:
- How does that impact testing if the content is changeable??

Notes:
- Create an edit link next to each document name on the index page
  - When edit link is clicked, they are taken to a new edit page
    - Implement a button or hyperlink to edit page?
- When the user views the edit page, the content should appear with a text area
  - Render the content in the edit box?
     - What HTML do I need for editing? Is it a form? - POST - changes data
     - pass the content to the edit page
     - have a button to save the chnges - POST
        - use the content

Steps to implement:
- Create an edit link next to each document - use a tags
- Create a route that takes user to edit page
  - Create a view template that shows the editing form
  - Create a button to save changes
- Render the content in the edit text box
- Create a route that submits a post request with the edited content
- Create a method to save the overwrite the file with the edited content
  - What methods can I use here? Check ruby File documents.

- Create a test case for th editing page?
  - How to test?
  - Make two requests for before edit and after edit?
  - Assert include should represent the before and after edit

=end
