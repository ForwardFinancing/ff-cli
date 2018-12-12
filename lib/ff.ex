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

  defmodule CLI do
    def main(args) do
      { opts, args, _ } = OptionParser.parse(args)
      case args do
        ["who-has" | extra_args] -> who_has(extra_args)
      end

      apps = Map.values(FF.repo_apps)
    end

    def who_has([app]) do
      repo = Enum.find(FF.repo_apps, fn {key, value} -> value == app end) |> elem(0)
      heroku_token = Netrc.read["api.heroku.com"]["password"]
      github_creds = Netrc.read["github.com"]
      {:ok, response} = HTTPoison.get(
        "https://api.heroku.com/apps/#{app}/releases",
        [
          {"Accept", "application/vnd.heroku+json; version=3"},
          {"Range", "id; order=desc"},
          {"Authorization", "Bearer #{heroku_token}"}
        ])
      {:ok, releases} = Poison.decode(response.body)
      last_deploy = Enum.find(releases,
        fn(r) ->
          r["description"] |> String.starts_with?("Deploy")
        end)
      ["Deploy", deployed_sha] = last_deploy["description"] |> String.split(" ")

      {:ok, response} = HTTPoison.get(
        "https://api.github.com/repos/ForwardFinancing/#{repo}/branches",
        [],
        hackney: [basic_auth: {github_creds["login"], github_creds["password"]}])
      {:ok, branches} = Poison.decode(response.body)
      deployed_branch = Enum.find(branches, fn(b) ->
        b["commit"]["sha"] |> String.starts_with?(deployed_sha) end)["name"]
      last_deployer = last_deploy["user"]["email"]
      last_deploy_at = Timex.parse(last_deploy["updated_at"], "{ISO:Extended}")
                       |> elem(1)
                       |> Timex.Timezone.convert(Timex.Timezone.local)
      # TODO: Make the strings have some color.
      header = "#{repo} ** #{app}"
      IO.puts("#{header}
#{"-" |> String.duplicate(header |> String.length)}
Deployed Branch: #{deployed_branch || "Not in sync with GitHub"}
Deployed By:     #{last_deployer}
Deployed At:     #{last_deploy_at}")
    end
  end
end
