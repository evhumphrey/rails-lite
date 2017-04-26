require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'byebug'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double Render Error" if already_built_response?

    # equiv to @res.redirect
    @res.status = 302
    @res.location = url

    @already_built_response = true

    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double Render Error" if already_built_response?

    # set content_type attribute in header equiv to set_header
    @res['Content-type'] = content_type

    # sets body
    @res.write(content)
    @already_built_response = true

    # sets cookie in response (as cookie for client to save)
    # just keep on adding stuff to the response (until res.finish is called in server)
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # "views/#{controller_name}/#{template_name}.html.erb"

    # format view path
    controller_name = self.class.to_s.underscore
    view_path = "views/#{controller_name}/#{template_name}.html.erb"

    # read in contents of view file and interpret embedded ruby
    view_content = File.read(view_path)
    template_content = ERB.new(view_content).result(binding) # binding gives erb access to ivars

    # html/text downloads output???
    render_content(template_content, "text/html")
  end

  # method exposing a `Session` object
  def session
    # lazy assign so session persists for entire controller life
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
