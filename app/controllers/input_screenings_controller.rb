class InputScreeningsController < Remote::RemotableController
  layout "emulator_project"
  
  def show_respond_to(format)
    object = if params[:output_id]
      @input_screening.screening_values.where(output_id: params[:output_id]).first
    else
      @input_screening
    end
    format.json {
      render json: object.to_hash
    }
    format.matlab {
      render text: object.to_matlab
    }
    format.r {
      render text: object.to_r
    }
  end
end
