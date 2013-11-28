module Remote
  class RemotableController < ApplicationController
    #before_filter :clean_projects, :only => :show
    before_filter :init_project, :only => :new
    before_filter :find_project, :is_allowed, :except => [:new, :show]

    # this needs code to handle has_many relationships too for emulator?
    # 
    
    def new
      set_instance_object(@project.send("build_#{instance_singular}"))
      instance = get_instance_object
      if instance.respond_to? :calculate_defaults
        instance.calculate_defaults
      end
    end

    def edit
      set_instance_object(instance_constantized.find(params[:id]))
    end

    def create
      # workaround for mongoid bug
      @project.send(instance_singular).destroy unless @project.send(instance_singular).nil?

      set_instance_object(@project.send("build_#{instance_singular}", params[instance_singular.to_sym]))

      if get_instance_object.save
        # start off task
        Delayed::Job.enqueue RemoteJob.new(get_instance_object)
        flash[:warn] = "#{instance_constantized.to_s} #{get_instance_object._id.to_s} is now tied to your session which will <b>automatically expire after 24 hours</b>."
        redirect_to send("#{instance_plural}_path")
      else
        render "new"
      end
    end

    def update
      set_instance_object(instance_constantized.find(params[:id]))
      get_instance_object.update_attributes(params[instance_singular.to_sym])

      if get_instance_object.save
        # start off task
        Delayed::Job.enqueue RemoteJob.new(get_instance_object)

        redirect_to send("#{instance_plural}_path", nil)
      else
        render "edit"
      end
    end

    def index
      set_instance_object(@project.send(instance_singular))

      # redirect to new if no object has been created
      if get_instance_object.nil?
        redirect_to send("new_#{instance_singular}_path")
      else
        # otherwise go to object
        redirect_to send("#{instance_singular}_path", get_instance_object)
      end
    end

    def show
      @object = instance_constantized.find(params[:id])
      set_instance_object(@object)
      respond_to do |format|
        show_respond_to(format) if self.class.method_defined?(:show_respond_to)
        format.json {
          render json: @object.to_hash
        }
        format.matlab {
          render text: @object.to_matlab
        }
        format.r {
          render text: @object.to_r
        }
        format.html { render :formats => [:html] }
        format.js { render :formats => [:js] }
      end
    end

    protected

    def clean_projects
      project_constantized.where(:created_at.lte => 24.hours.ago).destroy_all
    end

    def init_project
      case instance_singular.to_s
      when "validation"
        params = { :name => session[:session_id] }
      else
        params = {}
      end

      @project = project_constantized.new(params)

      if @project.save
        session[project_id_sym] = @project._id.to_s
      else
        # error message?
      end
    end

    def find_project
      if session[project_id_sym].nil?
        init_project
      else
        @project = project_constantized.find(session[project_id_sym])
      end
    end

    def is_authorized
      authorize! :manage, @project
    end

    def is_allowed
      if !@project.send("allow_#{instance_singular}?")
        needs = @project.send("needs_for_#{instance_singular}")
        flash[:error] = "You must complete the #{needs.to_sentence.gsub(/_/, ' ')} #{"stage".pluralize(needs.size)} first."
        redirect_to @project
      end
    end
    
    private
    
    def set_instance_object(object)
      instance_variable_set("@#{instance_singular}", object)
    end
    
    def get_instance_object
      instance_variable_get("@#{instance_singular}")
    end
    
    def instance_singular
      controller_name.classify.underscore.singularize
    end

    def instance_plural
      controller_name.classify.underscore.pluralize
    end

    def instance_constantized
      controller_name.classify.constantize
    end

    def project_singular
      @project.class.to_s.underscore.singularize
    end

    def project_constantized
      "#{instance_constantized.to_s}Project".classify.constantize
    end

    def project_id_sym
      "#{instance_singular}_project_id".to_sym
    end
  end
end