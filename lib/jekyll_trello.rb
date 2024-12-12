class JekyllTrello
  def self.creater(idList)
    bundle_install
    Dir.mkdir("_plugins") unless Dir.exist?("_plugins")
    content = <<~RUBY
      require 'dotenv/load'
      require 'trello'
      # require 'pry'
      module Jekyll
        class ContentCreatorGenerator < Generator
          safe true
          ACCEPTED_COLOR = "green"

          def setup
            @trello_api_key = ENV['TRELLO_API_KEY']
            @trello_token = ENV['TRELLO_TOKEN']

            Trello.configure do |config|
              config.developer_public_key = @trello_api_key
              config.member_token = @trello_token
            end
          end

          def generate(site)
            setup
            
            cards = Trello::List.find("#{idList}").cards
            cards.each do |card|
              labels = card.labels.map { |label| label.color }
              next unless labels.include?(ACCEPTED_COLOR)
              due_on = card.due&.to_date.to_s 
              slug = card.name.split.join("-").downcase
              created_on = DateTime.strptime(card.id[0..7].to_i(16).to_s, '%s').to_date.to_s
              article_date = due_on.empty? ? created_on : due_on
              content = """---
              layout: post
              title: \#{card.name}
              date: \#{article_date}
              permalink: \#{slug}
              ---

              \#{card.desc}
              """
              file_path = "./_posts/\#{article_date}-\#{slug}.md"
              File.open(file_path, "w+") { |f| f.write(content) }
            end
          end
        end
      end
    RUBY

    file_path = "_plugins/creater.rb"
    File.write(file_path, content)
    puts "File '#{file_path}' has been created successfully!"
  end

  def self.github
    ruby_version
    scripts
    env_gitignore
    content= <<~'RUBY'
name: Build blogs from Trello Card

on:
  push:
    branches:
      - gh-pages
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:

jobs:
  build-and-deploy:
    name: Build and commit on same branch
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v2
      
      - name: create .env file
        run: echo "${{ secrets.DOT_ENV }}" > .env
      
      - name: Setup ruby 
        run: echo "::set-output name=RUBY_VERSION::$(cat .ruby-version)"
        id: rbenv
      
      - name: Use Ruby ${{ steps.rbenv.outputs.RUBY_VERSION }}
        uses: ruby/setup-ruby@v1
      
      - name: Use cache gems
        uses: actions/cache@v1
        with:
          path: vendor/bundle
          key: ${{ runner.os }}-gem-${{ hashFiles('**/Gemfile.lock') }}
          restore-keys: |
            ${{ runner.os }}-gem-

      - name: bundle install
        run: |
          gem install bundler -v 2.4.22
          bundle install --jobs 4 --retry 3 --path vendor/bundle
      
      - name: rm posts
        run: |
          cp ./scripts/rmposts.sh _posts/rmposts.sh
          chmod +x _posts/rmposts.sh
          cd _posts
          sh rmposts.sh
          rm rmposts.sh
          cd ..
      - name: Build posts
        run: |
          bundle exec jekyll build
          
      - uses: EndBug/add-and-commit@v7
        with:
          add: '*.md'
          author_name: Habi Pyatha
          branch: gh-pages
          message: 'auto commit'
    RUBY
    Dir.mkdir(".github") unless Dir.exist?(".github")
    Dir.mkdir(".github/workflows") unless Dir.exist?(".github/workflows")
    file_path = ".github/workflows/build-block.yml"
    File.write(file_path, content)
    puts "File '#{file_path}' has been created successfully!"

  end

  def self.ruby_version
    file_path = ".ruby-version"
    File.write(file_path, "3.3.4")
    puts "File '#{file_path}' has been created successfully!"
  end

  def self.scripts
    content= <<~'RUBY'
counts= `ls -1 *.md 2>/dev/null | wc-1`
if [ $count != 0]
then 
echo true
echo "Removing all md files"
rm *.md
fi
    RUBY
    Dir.mkdir("scripts") unless Dir.exist?("scripts")
    file_path = "scripts/rmposts.sh"
    File.write(file_path, content)
    puts "File '#{file_path}' has been created successfully!"

  end

  def self.bundle_install
    gemfile_path = "Gemfile"

    unless File.exist?(gemfile_path)
      gemfile_content=<<~GEMFILE
      source 'https://rubygems.org'

      gem 'ruby-trello'
      gem 'dotenv'
      GEMFILE
      File.write(gemfile_path, gemfile_content)
    else
      gemfile_content = File.read(gemfile_path)

      unless gemfile_content.include?("dotenv")
        gemfile_content +="\ngem 'dotenv' \n"
      end
      unless gemfile_content.include?("ruby-trello")
        gemfile_content +="\ngem 'ruby-trello' \n"
      end

      File.write(gemfile_path,gemfile_content)
      puts "Gems 'ruby-trello' and 'dotenv' added to Gemfile."

    end
    system("bundle install")
    puts "Gems installed successfully!"
  end

  def self.env_gitignore
    gitignore_path=".gitignore"

    if File.exist?(gitignore_path)
      gitignore_content = File.read(gitignore_path)

      unless gitignore_content.include?(".env")
        File.open(gitignore_path, "a") do |file|
          file.puts(".env")  
        end
        puts ".env has been added to .gitignore"
      else
        puts ".env is already in .gitignore"
      end
    else
      puts "No .gitignore file found. Please create one first."
    end

  end
  


end

idList = "6759348bb364c0a0ad05e54c"
JekyllTrello.creater(idList)
# JekyllTrello.github
# JekyllTrello.ruby_version
# JekyllTrello.scripts
# JekyllTrello.bundle_install
JekyllTrello.env_gitignore
