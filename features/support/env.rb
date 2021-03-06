require 'fileutils'

def install_fixture_gems
  throw Error.new("Bugsnag.gem not found. Is this running in a docker-container?") unless File.exist?("/app/bugsnag.gem")
  Dir.entries('features/fixtures').reject { |entry| ['.', '..'].include?(entry) }.each do |entry|
    target_dir = "features/fixtures/#{entry}"
    if File.directory?(target_dir)
      `cp /app/bugsnag.gem #{target_dir}`
      `gem unpack #{target_dir}/bugsnag.gem --target #{target_dir}/temp-bugsnag-lib`
    end
  end
end

AfterConfiguration do |config|
  install_fixture_gems
end

Before do
  Docker.compose_project_name = "#{rand.to_s}:#{Time.new.strftime("%s")}"
  Runner.environment.clear
  Runner.environment["BUGSNAG_API_KEY"] = $api_key
  Runner.environment["BUGSNAG_ENDPOINT"] = "http://maze-runner:#{MOCK_API_PORT}"
end
