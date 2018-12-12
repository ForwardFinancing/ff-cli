defmodule FF do
  @repo_apps %{
    "competitor_inquiries"     => "competitor-inquiries-staging",
    "domain_service"           => "domain-service-staging",
    "advance_report"           => "ff-advance-report-staging",
    "auth-frontend"            => "ff-auth-frontend-staging",
    "auth"                     => "ff-auth-staging",
    "banking"                  => "ff-banking-staging",
    "dashboard"                => "ff-dashboard-staged",
    "data_pipeline"            => "ff-data-pipeline-staging",
    "data_validations"         => "ff-data-validations-staging",
    "funding"                  => "ff-funding-staging",
    "naics_provider"           => "ff-naics-provider-staging",
    "partner_api"              => "ff-partner-api-staging",
    "payment-history-frontend" => "ff-payment-history-ui-staging",
    "paynet_reporter"          => "ff-paynet-reporter-staging",
    "the_predictor"            => "ff-predictor-staging",
    "prequal-portal"           => "ff-prequal-portal-staging",
    "productive"               => "ff-productive-staging",
    "queue-service"            => "ff-queue-service-staging",
    "queue-frontend"           => "ff-queue-staging",
    "sf_service"               => "ff-sf-service-staging",
    "salesforce_webhooks"      => "ff-sf-webhooks-staging",
    "showcase"                 => "ff-showcase-staging",
    "underwriting"             => "ff-underwriting-staging",
    "merchant-portal"          => "merchant-portal-staging",
    "partner-portal"           => "partner-portal-staging",
    "partner_sub_munger"       => "partner-sub-munger-staged",
    "password-safety"          => "password-safety-staging",
    "reporting_engine"         => "reports-staged",
    "vintage"                  => "vintage-staged"
  }

  def repo_apps, do: @repo_apps

  defmodule Heroku do
    def releases(app, creds) do
      {:ok, response} = HTTPoison.get(
        "https://api.heroku.com/apps/#{app}/releases",
        [
          {"Accept", "application/vnd.heroku+json; version=3"},
          {"Range", "id; order=desc"},
          {"Authorization", "Bearer #{creds["password"]}"}
        ])
      {:ok, releases} = Poison.decode(response.body)
      releases
    end
  end

  defmodule GitHub do
    def branches(repo, creds) do
      {:ok, response} = HTTPoison.get(
        "https://api.github.com/repos/ForwardFinancing/#{repo}/branches",
        [],
        hackney: [basic_auth: {creds["login"], creds["password"]}])
      {:ok, branches} = Poison.decode(response.body)
      branches
    end
  end

  defmodule CLI do
    def main(args) do
      { opts, args, _ } = OptionParser.parse(args)
      case args do
        ["who-has" | extra_args] -> who_has(extra_args)
      end

      apps = Map.values(FF.repo_apps)
    end

    def who_has([app]) do
      heroku_creds = Netrc.read["api.heroku.com"]
      github_creds = Netrc.read["github.com"]

      # Get a list of releases of the app.
      releases = FF.Heroku.releases(app, heroku_creds)
      last_deploy = Enum.find(releases,
        fn(r) ->
          r["description"] |> String.starts_with?("Deploy")
        end)

      # Parse out the last deploy SHA.
      ["Deploy", deployed_sha] = last_deploy["description"] |> String.split(" ")

      # Pull out some other information to display.
      last_deployer = last_deploy["user"]["email"]
      last_deploy_at = Timex.parse(last_deploy["updated_at"], "{ISO:Extended}")
                       |> elem(1)
                       |> Timex.Timezone.convert(Timex.Timezone.local)

      # If there's a map from the given app name to a GitHub repo and we have
      # GitHub credentials then we can _try_ to find the corresponding branch
      # name.
      repo_app_map = Enum.find(FF.repo_apps, fn {key, value} -> value == app end)
      if repo_app_map && github_creds do
        repo = repo_app_map |> elem(0)

        # Get all the branches for the repo corresponding to the app.
        branches = FF.GitHub.branches(repo, github_creds)

        # Find the branch's HEAD commit that matches the deployed commit SHA.
        deployed_branch = Enum.find(branches, fn(b) ->
          b["commit"]["sha"] |> String.starts_with?(deployed_sha) end)["name"]

        header = "#{repo} ** #{app}"
        IO.puts("#{header}
#{"-" |> String.duplicate(header |> String.length)}
Deployed Branch: #{deployed_branch || "Not in sync with GitHub"}
Deployed By:     #{last_deployer}
Deployed At:     #{last_deploy_at}")
      else
        IO.puts("#{app}
#{"-" |> String.duplicate(app |> String.length)}
Deployed Commit: #{deployed_sha}
Deployed By:     #{last_deployer}
Deployed At:     #{last_deploy_at}")
      end
    end
  end
end
