Gem::Specification.new do |s|
  s.name        = 'jekyll_trello'
  s.version     = '0.1.0'
  s.executables = ["jekyll_trello"]

  s.summary     = "This is will help you setup your jekyll website in github and take data from trello automatically once a day if label is set to green."
  s.description = "Extract the trello cards details and show it in your trello website also automatically runs daily if hosted on github"
  s.authors     = ["Habi Coder"]
  s.email       = 'unionhab@gmail.com'
  s.files       = ["lib/jekyll_trello.rb","bin/jekyll_trello"]
  s.homepage    = "https://github.com/Habi-Pyatha"
  s.metadata    = { "source_code_uri" => "https://github.com/Habi-Pyatha" }
end