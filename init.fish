if not type -q npm
  if test -d /usr/local/share/npm/bin
    if not contains /usr/local/share/npm/bin $PATH
      set PATH /usr/local/share/npm/bin $PATH
    end
  else if test -n "$NPM_DIR"; and test -d $NPM_DIR
    if not contains $NPM_DIR $PATH
      set PATH $NPM_DIR $PATH
    end
  else
    echo "plugin-node: npm is unavailable, either install it or set $NPM_DIR"
    echo "             in the config.fish file: set NPM_DIR /path/to/npm/dir"
  end
end

function __update_node_paths --on-variable PWD --description "check dir"
    status --is-command-substitution; and return

    # These should probably be config variables, but I'm feeling lazy.
    set workDir "$HOME/work"
    set nodeModules "node_modules/.bin"

    # Remove work dir node modules from path
    set x 1
    for path in $PATH
        # echo "checking \^$workDir/.*/$nodeModules against $path"
        if string match -r -q "^$workDir/.*/$nodeModules" "$path"
            set --erase PATH[$x]
            # echo "PATH is now $PATH"
        end
        set x (math --scale $x + 1)
    end

    set currentDir (pwd)

    # pop directories off current dir until we find node_modules or
    # we exit the work dir.
    while true;
        if not string match -r -q "^$workDir/.*" "$currentDir"
            # echo "Not in work dir"
            break
        end
        set nodePath (string join / $currentDir node_modules/.bin)

        # Add the first node_modules directory found to the PATH
        if test -d $nodePath
            if not contains $nodePath $PATH
              set PATH $nodePath $PATH
              # echo "Adding path:$nodePath"
            end
            break
        end

        # Abort when we reach the root dir "/"
        if test $currentDir = (dirname $currentDir)
            break
        end

        set currentDir (dirname $currentDir)
    end

end

__update_node_paths
