class ValidationsController < Remote::RemotableController

  alias :super_create :create

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

    params[:validation][:observed] = observed
    params[:validation][:predicted] = predicted
    
    super_create
  end
end
