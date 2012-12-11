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

  private

  def parse_value(value)
    begin
      JSON.parse(value)
    rescue JSON::ParserError
      value.to_f
    end
  end
end
