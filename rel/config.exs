use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

cookie = :sha256
|> :crypto.hash(System.get_env("ERLANG_COOKIE") || "ZS3RsvmAmHmNsJiZbd8ZjAWngo8zzZF0IGYOvUsb58Wc6vuFhtrGubsp7XQVV3Oo")
|> Base.encode64

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: cookie
end

release :ops_api do
  set version: current_version(:ops_api)
  set applications: [
    ops_api: :permanent
  ]
end
