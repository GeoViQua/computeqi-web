Fabricator(:simulator_specification) do 
  service_url 'http://uncertws.aston.ac.uk:8080/ps/service'
  process_name 'Polyfun'
  process_description ''
  inputs [
    Input.create(name: 'A', minimum_value: 100, maximum_value: 1000),
    Input.create(name: 'B', minimum_value: 10, maximum_value: 15)
  ]
  outputs [ Output.create(name: 'Result') ]
end