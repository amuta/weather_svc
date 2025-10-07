SimpleCov.configure do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Lib', 'app/lib'
  add_group 'Clients', 'lib/clients'
  add_group 'Helpers', 'lib/http_helpers.rb'
end
