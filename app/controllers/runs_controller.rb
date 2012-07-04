class RunsController < Remote::RemotableController
  layout "emulator_project"
  
  def show_respond_to(format)
    format.json {
      if params[:output_id]
        value = @run.run_values.where(output_id: params[:output_id]).first
        render json: value.to_hash
      else
        render json: @run.to_hash
      end
    }
  end
end
