require "emulatorization"

namespace :e do

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