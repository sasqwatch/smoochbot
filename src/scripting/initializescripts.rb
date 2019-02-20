require_relative "find_writeable_dirs"
require_relative "fix_path"
require_relative "find_languages"

def create_startup_scripts
  scripts = []
  #scripts << FindWriteableDirs.new
  scripts << FixPath.new
  scripts << FindLanguages.new
end


def create_shell_scripts
  scripts = []
  scripts << FindWriteableDirs.new
  scripts << FixPath.new
end