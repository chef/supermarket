require "mixlib/shellout" unless defined?(Mixlib::ShellOut)
require "dotenv-rails"
Dotenv.load(".env")
require "shellwords" unless defined?(Shellwords)

module CookstyleHelpers
  def self.process_artifact(path)
    path = path.shellescape
    shell_out = Mixlib::ShellOut.new("cookstyle #{path} --only #{ENV["COOKSTYLE_COPS"]} --format json")
    shell_out.run_command
    parse_cookstyle_output(shell_out.stdout)
  rescue StandardError => e
    raise "Error in processing Artifact #{e.message}"
  end

  # "COP_NAME":"MESSAGE":"file_name:line=line_no,col=col_no"
  def self.parse_cookstyle_output(cookstyle_output)
    status = ""
    offenses_arr = JSON.parse(cookstyle_output)["files"].map { |h|
      h["offenses"]\
        .each { |a| a.merge!("file" => h["path"]) }
    }                   \
      .flatten.sort_by { |hsh| hsh["cop_name"] }\
      .each { |a|
        status << "#{[a["cop_name"], a["message"],\
    a["file"], a["location"]["line"]].join(": ")}\n"
      }

    [status, offenses_arr.size > 0]
  end
end