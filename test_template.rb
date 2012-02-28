require 'rubygems'
require 'erubis'

template_file = "results2.html.erb"
template = Erubis::Eruby.load_file(template_file)
clients = ['cli_c','cli_ruby','cli_java','avro','protobufs']
inputs = ['sp', 'li']
tests = ['accuracy', 'time']

data = {}
clients.each do |client|
  data[client] = {}
  tests.each do |test|
    data[client][test] = {}
    inputs.each do |object|
      data[client][test][object] = 1
    end
  end
end


File.open("results.html", "w") do |f|
  f.write template.result({
    :clients => clients,
    :tests => tests,
    :inputs => inputs,
    :data => data
  })
end
