# Smoochbot
A shell handler/script runner. Supports linux only (once I'm comfortable with how it functions with linux shells, I'll add support for windows shells), also assumes that python and 'stty' are available (I have plans to remove this). Writing your own scripts is highly encouraged, and I'd be happy to add any custom scripts to the repo!
Lots of features planned, such as 
Persistent history
Tab completion
And many more scripts!
I'm stepping away from the project to focus on school for about 2 months, I'll start adding/improving features after that. 
### Usage
There are 5 scripts currently written for smoochbot, their names and invocations are as follows. All 5 can be invoked with their keywords. FixPath, FindLanguages, and FindTools are run as soon a shell connection is received.
##### FindWriteableDirs - fwd
Searches for all directories writeable by the current user
##### FixPath - fp
Adds common path locations to the PATH variable
##### FindLanguages - fl
Searches for and prints available languages
##### FindTools - ft
Searches for and prints available network oriented tools (nc, fetch, ftp, etc.)
##### SUIDBitCheck -suidbitcheck
Searches for nmap and vim executables owned by root with their SUID bits set

None of the searches except FindWriteableDirs are exhaustive, if you have a suggestion for something that should be searched for please suggest it, I'll be happy to add it.
