require "emulatorization"

class RemoteJob < Struct.new(:remotable)
  
  def enqueue
    remotable.proc_start_time = nil
    remotable.proc_end_time = nil
    remotable.proc_status = "queued"
    remotable.proc_message = nil
    remotable.save
  end
  
  def before
    remotable.proc_start_time = DateTime.now
    remotable.proc_end_time = nil
    remotable.proc_status = "in_progress"
    remotable.proc_message = nil
    remotable.save
  end
  
  def perform
    # post
    response = Emulatorization::API.send(remotable.generate, { read_timeout: 4.hour })

    # check result
    if response['type'] == 'Exception'
      # errors!
      remotable.proc_status = "error"
      remotable.proc_message = response['message']
    else
      remotable.handle(response)
      remotable.proc_status = "success"
    end
  end
  
  def after
    # always fired, even with an error
    remotable.proc_end_time = DateTime.now
    remotable.save
  end

  def success
  end

  def error(job, exception)
    remotable.proc_message = exception
  end

  def failure
    remotable.proc_status = "error"
    remotable.proc_message = "Failure executing job: " + remotable.proc_message
    remotable.save
  end
  
end