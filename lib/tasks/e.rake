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

  def update_descriptions(desc_coll, coll)
    desc_coll.each do |desc|
      io = coll.where(name: desc["identifier"]).first
      io.description = desc["description"]["detail"]
      io.uom = desc["description"]["uom"]
      io.save
    end
  end

end