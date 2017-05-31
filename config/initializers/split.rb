require 'split/dashboard'
include Split::Helper

Split.configure do |config|
  config.db_failover = true # handle redis errors gracefully
  config.db_failover_on_db_error = -> (error) { Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true
  config.persistence = Split::Persistence::SessionAdapter
  #config.start_manually = false ## new test will have to be started manually from the admin panel. default false
  config.include_rails_helper = true
  config.redis = "redis://redistogo:94ad03b5dae43c4ae2970067eb24876e@porgy.redistogo.com:10158/"
end