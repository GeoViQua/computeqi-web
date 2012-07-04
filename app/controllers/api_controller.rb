require "emulatorization"

class ApiController < ApplicationController
  # Currently only works if logged in

  def index
    respond_to do |format|
      format.html {
        # Display documentation
        render
      }
      format.json {
        # Process API request
        # TODO: this call blocks, need to use em-http-request or something
        render json: Emulatorization::API.send_string(params[:request], { read_timeout: nil })
      }
    end
  end

end