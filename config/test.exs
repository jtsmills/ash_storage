import Config

config :ash_storage, AshStorage.TestRepo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ash_storage_test",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :ash_storage,
  ecto_repos: [AshStorage.TestRepo]

config :ash_storage, :oban,
  testing: :manual,
  repo: AshStorage.TestRepo,
  plugins: [{Oban.Plugins.Cron, []}],
  queues: [ash_storage_purge_blob: 1]
