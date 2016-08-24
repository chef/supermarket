module VersionBumper
  class << self
    def next_version(repository)
      file_major, file_minor = current_version(repository).split('.')
      tag_major, tag_minor, tag_patch = latest_tag(repository).split('.')

      # Only bump the patch version if the `MAJOR` and `MINOR`
      # have not changed.
      new_patch = if (file_major == tag_major) && (file_minor == tag_minor)
                    tag_patch.to_i + 1
                  else
                    0
                  end
      [file_major, file_minor, new_patch].join('.')
    end

    def latest_tag(repository)
      output = nil
      Dir.chdir(repository) do
        output = `git tag -l | sort -V | tail -n1`.chomp
      end
      if $? != 0
        raise "Cannot git most recent tag: #{output}"
      else
        output
      end
    end

    def current_version(repository)
      ::File.read(File.join(repository, 'VERSION')).chomp
    end
  end
end
