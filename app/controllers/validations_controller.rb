class ValidationsController < Remote::RemotableController
  def create
    observed_raw = params[:validation][:observed]
    predicted_raw = params[:validation][:predicted]

    observed_hash = Hash[observed_raw[:ids].zip observed_raw[:values]]
    predicted_hash = Hash[predicted_raw[:ids].zip predicted_raw[:values]]
    
    observed = Array.new
    predicted = Array.new

    observed_hash.each do |id, value|
      observed << value.to_f
      predicted << predicted_hash[id].split(',').map {|value| value.to_f }
    end

    logger.info observed
    logger.info predicted

    params[:validation][:observed] = observed
    params[:validation][:predicted] = predicted
    super
  end
end
