# spec/support/vcr_setup.rb
VCR.configure do |c|
  #the directory where your cassettes will be saved
  c.cassette_library_dir = 'spec/support/vcr'
  # your HTTP request service. You can also use fakeweb, webmock, and more
  c.hook_into :webmock
end