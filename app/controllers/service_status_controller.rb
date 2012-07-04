require "emulatorization"

class ServiceStatusController < ApplicationController  
  def index
    respond_to do |format|
      format.html {
        # Display page
        render
      }
      format.json {
        # Could be done separately for maximum accuracy!
        # TODO: this call blocks, need to use em-http-request or something
        render json: Emulatorization::API.send({ type: "StatusRequest" }, { read_timeout: 5.seconds })
      }
    end
  end
end