class ValidationsController < Remote::RemotableController

  alias :super_create :create

  def create
    if @project.class == ValidationProject
      observed_hash = params[:validation][:observed]
      predicted_hash = params[:validation][:predicted]

      observed = Array.new
      predicted = Array.new

      missing_value = params[:validation][:missing_value_code].to_f

      observed_hash.each do |id, value|
        parsed_obs = parse_value(value)
        parsed_pred = parse_value(predicted_hash[id])
        if parsed_obs != missing_value and parsed_pred != missing_value
          observed << parsed_obs
          predicted << parsed_pred
        end
      end

      params[:validation][:observed] = observed
      params[:validation][:predicted] = predicted
    end
    super_create
  end

  def edit
    # to get try again link working
    refresh
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
    redirect_to validation_path(@validation)
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
