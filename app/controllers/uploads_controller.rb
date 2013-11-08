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
    headers = []
    rows = []
    datasets = {}

    # tmp zip that has been uploaded
    zip = params[:file].tempfile

    # base working directory for the zip contents
    basedir = "../workspace"
    
    # read the zip
    begin
      zipfile = Zip::File.open(zip)

      # parse the report definition
      report = JSON.parse(zipfile.read("#{basedir}/report_definition.json"))["report"]

      # the main variable and its units
      main_var = Hash[ [:name, :units].zip(report["components"]["_confparam"]["dict"]["main variable"].strip.split(/\s+/, 2)) ]

      # start processing each dataset
      report["datasets"].each do |key, dataset|
        datasets[key.to_sym] = []
        headers << "#{dataset["name"]} (#{key})"

        # read each netcdf file in the dataset
        dataset["files"].each do |f|
          file = Tempfile.new(File.basename("#{f}"))
          file.binmode

          begin
            # write the contents to the actual filesystem and open it
            file.write zipfile.get_input_stream("#{basedir}/#{f}").read
            netcdf = NumRu::NetCDF.open(file.path)

            # get the length of the first dimension and read its values
            netcdf.var(main_var[:name]).dim(0).length.times do |index|
              datasets[key.to_sym] << netcdf.var(main_var[:name]).get[index]
            end
          ensure
            netcdf.close
            file.close
          end
        end
      end
    rescue Errno::ENOENT => ex
      return error(ex.message)
    ensure
      zip.close
    end

    # csv header
    rows << headers

    # csv values
    table = datasets.values.transpose
    table.each do |row|
      rows << row
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