require 'csv'
require 'zip'
require 'numru/netcdf'

class UploadsController < ApplicationController
  def create
    # "file"=>#<ActionDispatch::Http::UploadedFile:0x007f9fcae92138
    # @original_filename="ens_no2_hoogvliet_20110402_20110408_24h.csv",
    # @content_type="text/csv"

    @filename = params[:file].original_filename
    @mimetype = params[:file].content_type

    case @mimetype
    when "text/plain", "text/csv", "application/vnd.ms-excel"
      response = parse_csv
    when "application/zip"
      response = parse_zip
    else
      response = error("Unable to process #{filename}, incompatible mimetype: #{mimetype}")
    end

    render :json => response
  end

  def parse_csv
    rows = []

    CSV.parse(params[:file].read).each do |row|
      rows << row
    end

    return rows
  end

  def parse_zip
    rows = []
    datasets = {}
    file = params[:file].tempfile
    basedir = "../workspace"
    
    begin
      zipfile = Zip::File.open(file)
      report = JSON.parse(zipfile.read("#{basedir}/report_definition.json"))["report"]
      main_var = Hash[ [:name, :units].zip(report["components"]["_confparam"]["dict"]["main variable"].strip.split(/\s+/, 2)) ]
      rows << main_var[:name]
      rows << main_var[:units]
    rescue Errno::ENOENT => ex
      return error(ex.message)
    ensure
      file.close(true)
    end

    return rows
  end

  def error(message)
    {
      error: {
        code: 500,
        message: message
      }
    }
  end
end