defmodule PushHub.Mixfile do
  use Mix.Project

  def project do
    [app: :push_hub,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Push Service Http Client for Elixir (Aliyun Push)",
     package: package,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :poison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     {:poison, "~> 2.2.0"},
     {:httpoison, "~> 0.9.1"},
     {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :push_hub,
      files: ["mix.exs", "lib", "README*", "LICENSE*"],
      maintainers: ["Tsung Wu"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/reteq/push-hub"}
    ]
  end
end
