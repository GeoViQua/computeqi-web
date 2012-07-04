class DesignsController < Remote::RemotableController
  layout "emulator_project"

  def show_respond_to(format)
    format.json {
      if params[:input_id]
        value = @design.design_values.where(input_id: params[:input_id]).first
        render json: value.to_hash
      else
        render json: @design.to_hash
      end
    }
  end
end
