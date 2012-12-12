class ValidationsController < Remote::RemotableController

  alias :super_create :create

  def create
    observed_hash = params[:validation][:observed]
    predicted_hash = params[:validation][:predicted]

    observed = Array.new
    predicted = Array.new

    observed_hash.each do |id, value|
      observed << parse_value(value)
      predicted << parse_value(predicted_hash[id])
    end

    params[:validation][:observed] = observed
    params[:validation][:predicted] = predicted
    
    super_create
  end

  def show_respond_to(format)
    format.json {
      if params[:data]
        hash = @validation.send("#{params[:data]}_data")
        render json: hash.to_hash
      else
        render json: @validation.to_hash
      end
    }
  end

  def refresh
    @validation = Validation.find(params[:id])
    Delayed::Job.enqueue RemoteJob.new(@validation)
    redirect_to validation_project_validation_path(@project, @validation)
  end

  private

  def parse_value(value)
    begin
      JSON.parse(value)
    rescue JSON::ParserError
      value.to_f
    end
  end
end
