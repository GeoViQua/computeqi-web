module Remote
  module Remotable
    extend ActiveSupport::Concern
    
    included do
      field :proc_start_time, type: DateTime
      field :proc_end_time, type: DateTime
      field :proc_status, type: String # delayed_job will make this "queued" straight away
      field :proc_message, type: String
      validates_inclusion_of :proc_status, in: ["queued", "in_progress", "error", "success"], allow_blank: true
    end

    def queued?
      self.proc_status == "queued"
    end
    
    def in_progress?
      self.proc_status == "in_progress"
    end

    def finished?
      self.proc_status == "error" or self.proc_status == "success"
    end

    def success?
      self.proc_status == "success"
    end

    def error?
      self.proc_status == "error"
    end
  end
end