# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :generals, Generals.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8XR+MMysdDuC3oyk8igoXOJ9mTxb79k81H9v+3N4I3csPyxzPOt7a0JHqnk2oq/E",
  render_errors: [view: Generals.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Generals.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
