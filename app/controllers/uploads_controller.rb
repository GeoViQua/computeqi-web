require 'csv'

class UploadsController < ApplicationController
  def create
    # "file"=>#<ActionDispatch::Http::UploadedFile:0x007f9fcae92138
    # @original_filename="ens_no2_hoogvliet_20110402_20110408_24h.csv",
    # @content_type="text/csv"

    rows = []
    CSV.parse(params[:file].read).each do |row|
      rows << row
    end
    
    render json: rows
  end
end