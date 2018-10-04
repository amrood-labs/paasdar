require "amber/controller/base"

class Paasdar::SessionsController < Amber::Controller::Base
  include JasperHelpers

  LAYOUT = "mailer.html.ecr"

  def new
    user = User.new
    render("new.html.ecr")
  end

  def create
    user = User.find_by(email: params["email"].to_s)
    if user && user.authenticate(params["password"].to_s) && user.confirmed?
      user_logged_in = true
      session[:user_id] = user.id
      flash[:info] = "Successfully logged in!"
    else
      flash[:danger] = "Invalid email or password!"
    end
    # render_js("create.js.ecr")
  end

  def delete
    session.delete(:user_id)
    flash[:info] = "Logged out. See ya later!"
    redirect_to "/users/sign_in"
  end
end
