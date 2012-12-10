# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'headless'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  Capybara.current_driver = :rack_test
  Headless.new.start

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end

shared_context "twitter_login" do
  let!(:user) { FactoryGirl.create(:user) }
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[user.provider.to_sym] = {
      "provider" => user.provider,
      "uid" => user.uid,
      'info' => {
        'email' => user.mail,
        'nickname' => user.name,
        'image' => user.image
      }
    }

    visit "/auth/twitter"
  end
end

shared_context "visit_current_event" do
  let!(:event) { FactoryGirl.create(:event, group_id: group.id) }
  before do
    visit event_path(event)
  end
end
