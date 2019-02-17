require_relative "find_writeable_dirs"

def create_startup_scripts
  scripts = []
  #scripts << FindWriteableDirs.new
end


def create_shell_scripts
  scripts = []
  scripts << FindWriteableDirs.new
end