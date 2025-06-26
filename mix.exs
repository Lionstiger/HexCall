defmodule Hexcall.MixProject do
  use Mix.Project

  def project do
    [
      app: :hexcall,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Hexcall.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # phoenix
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:live_debugger, "~> 0.1.7", only: :dev},
      {:tidewave, "~> 0.1", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:flame_on, git: "https://github.com/DockYard/flame_on", only: :dev},

      # ecto
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_psql_extras, "~> 0.8.8"},

      # js
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},

      # Membrane Plugins
      {:membrane_core, "~> 1.2"},
      {:membrane_webrtc_plugin, "~> 0.25"},
      {:membrane_opus_plugin, "~> 0.20"},
      {:membrane_tee_plugin, "~> 0.12.0"},
      {:membrane_funnel_plugin, "~> 0.9.2"},
      {:membrane_audio_mix_plugin,
       github: "Lionstiger/membrane_audio_mix_plugin", branch: "master"},
      {:membrane_raw_audio_parser_plugin, "~> 0.4.0"},
      {:membrane_file_plugin, "~> 0.17", only: :dev},
      {:membrane_fake_plugin, "~> 0.11.0", only: :dev},
      {:membrane_matroska_plugin, "~> 0.6", only: :dev},
      {:membrane_portaudio_plugin, "~> 0.19.2", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd npm install --prefix assets"
      ],
      "assets.build": ["tailwind hexcall", "esbuild hexcall"],
      "assets.deploy": [
        "tailwind hexcall --minify",
        "esbuild hexcall --minify",
        "phx.digest"
      ]
    ]
  end
end
