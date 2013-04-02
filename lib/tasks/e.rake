require "emulatorization"

namespace :e do

  def send_remotable(remotable)
    remotable.proc_start_time = DateTime.now
    remotable.proc_status = "in_progress"
    remotable.save

    # send
    response = Emulatorization::API.send(remotable.generate, { read_timeout: 4.hour })

    # check result
    if response['type'] == 'Exception'
      # errors!
      remotable.proc_status = "error"
      remotable.proc_message = response['message']
      puts "Couldn't perform remote job: #{remotable.proc_message}"
    else
      remotable.handle(response)
      remotable.proc_status = "success"
    end

    remotable.proc_end_time = DateTime.now
    remotable.save
  end

  task :add_demo_data => :environment do
    count = 20
    (1..count).each do |n|
      puts "Adding demo account #{n} of #{count}"
      user = User.create(email: "demo#{n}@uncertweb.org", password: "password", first_name: "Demo", last_name: n)

      # create project
      project = EmulatorProject.create(name: "SimpleSimulator", user: user)

      # create simulator specification
      spec = project.create_simulator_specification(
        service_url: "http://uncertws.aston.ac.uk:8080/ps/service",
        process_name: "SimpleSimulator"
      )

      [ "Rainfall", "MeanAirTemperature", "MaxAirTemperation", 
        "MinAirTemperation", "MeanSoilN", "MaxSoilN", "MinSoilN", "MeanSoilC", "MaxSoilC", "MinSoilC", 
        "MeanSoilTemperature", "MaxSoilTemperation", "MinSoilTemperation", "MeanSoilWettingRate", 
        "MaxSoilWettingRate", "MinSoilWettingRate", "SoilPorosity", "SurfaceAlbedo", 
        "WheatSystolicPressure", "Evapotranspiration" ].each {|name| spec.inputs.create(name: name, minimum_value: 0, maximum_value: 1) }

      [ 'WheatGrowthRate', 'FinalYield', 'LargestWheatKernelSize' ].each {|name| spec.outputs.create(name: name) }

      # create screening
      screening = project.build_input_screening
      send_remotable(screening)

      # create design
      design = project.build_design
      design.simulator_specification = spec
      design.calculate_defaults
      send_remotable(design)

      # create run
      run = project.build_run
      run.simulator_specification = spec
      run.design = design
      send_remotable(run)

      # create emulator
      emulator = project.build_emulator
      emulator.output = spec.outputs.where(name: 'FinalYield').first
      emulator.calculate_defaults
      send_remotable(emulator)

      # create validation
      validation = project.build_validation
      validation.calculate_defaults
      send_remotable(validation)
    end
  end

  task :refresh_descriptions => :environment do
    SimulatorSpecification.all.each do |spec|
      desc = Emulatorization::API.send({
        type: "GetProcessDescriptionRequest",
        serviceURL: spec.service_url,
        processIdentifier: spec.process_name
      })["processDescription"]

      inputs = spec.inputs
      outputs = spec.outputs

      update_descriptions(desc["inputs"], inputs)
      update_descriptions(desc["outputs"], outputs)
    end
  end

  task :refresh_validations => :environment do
    Validation.all.each do |validation|
      Delayed::Job.enqueue RemoteJob.new(validation)
    end
  end

  task :convert_validations do
    db = mongo_get_db
    validations = db['validations']

    validations.find.each do |row|
      vpi = row['validation_project_id']
      if !vpi.nil?
        row['_type'] = 'Validation'
        row['validatable_id'] = vpi
        row['validatable_type'] = 'ValidationProject'
        row.delete('validation_project_id')
        validations.update({ '_id' => row['_id'] }, row)
      end
    end

    db['emulator_validations'].drop
    db['emulator_validation_values'].drop
  end

  task :upgrade_inputs => :environment do
    Input.all.each do |input|
      if input.fixed_value.nil?
        input.value_type = 'variable'
      else
        input.value_type = 'fixed'
      end
      input.save
    end
  end

  private

  def mongo_get_db
    all_config = YAML::load(ERB.new(File.read(Rails.root.join('config', 'mongoid.yml'))).result)
    env_config = all_config[Rails.env]
    if env_config.has_key?('uri')
      uri = URI.parse(env_config['uri'])
      Mongo::Connection::from_uri(env_config['uri']).db(uri.path.gsub(/^\//, ''))
    else
      Mongo::Connection.new(env_config['host'], env_config['port']).db(env_config['database'])
    end
  end

  def update_descriptions(desc_coll, coll)
    desc_coll.each do |desc|
      io = coll.where(name: desc["identifier"]).first
      io.description = desc["description"]["detail"]
      io.uom = desc["description"]["uom"]
      io.save
    end
  end

end