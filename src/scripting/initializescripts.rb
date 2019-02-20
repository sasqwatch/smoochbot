require_relative "find_writeable_dirs"
require_relative "fix_path"

def create_startup_scripts
  scripts = []
  #scripts << FindWriteableDirs.new
  scripts << FixPath.new
end


def create_shell_scripts
  scripts = []
  scripts << FindWriteableDirs.new
  scripts << FixPath.new
end