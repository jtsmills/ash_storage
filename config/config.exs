import Config

config :ash, :disable_async?, true
config :ash, :validate_domain_resource_inclusion?, false
config :ash, :validate_domain_config_inclusion?, false

config :logger, level: :warning

if config_env() == :test do
  import_config "test.exs"
end
