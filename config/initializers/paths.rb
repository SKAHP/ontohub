module PathsInitializer
  DEFAULT_PATHS = {git_repositories: 'repositories',
                   symlinks: 'git_daemon',
                   commits: 'commits',
                   git_home: 'git'}
  class << self
    def expand(path)
      Dir.chdir(Rails.root) { Pathname.new(path).expand_path }
    end

    def cleanup_release(path)
      path.sub(%r(/releases/\d+/), "/current/")
    end

    def prepare(path, fallback = nil)
      path = File.join(Settings.paths.data, fallback) if fallback && path.nil?
      cleanup_release(expand(path))
    end

    # Only defines methods to prevent NoMethodErrors
    # To be called before settings validation.
    def empty_initialization(config)
      config.data_root = nil
      config.git_root = nil
      config.git_home = nil
      config.symlink_path = nil
      config.commits_path = nil
    end

    # Actually performs initialization
    # To be called after settings validation
    def perform_initialization(config)
      config.data_root = prepare(Settings.paths.data)
      config.git_root = prepare(Settings.paths.git_repositories, DEFAULT_PATHS[:git_repositories])
      config.symlink_path = prepare(Settings.paths.symlinks, DEFAULT_PATHS[:symlinks])
      config.commits_path = prepare(Settings.paths.commits, DEFAULT_PATHS[:commits])
      config.git_home = prepare(Settings.paths.git_home, DEFAULT_PATHS[:git_home])
    end
  end
end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.empty_initialization(app.config)
  end
end
