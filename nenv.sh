# Simple virtual environments for Node
#
# A set of bash/zsh functions that provide simple virtual environment
# capabilities for node. To install, just copy this file into your home
# directory and add the following to your .bashrc or .zshrc file:

# if [[ -f "$HOME/.nenv/nenv.sh" ]]; then
#     source "$HOME/.nenv/nenv.sh"

#     # Uncomment the following line if you want virtual environments
#     # activated/deactivted as you cd into/out of them.
#     # alias cd="nenv_cd"

#     # Uncomment the following line if you want to try to check for a
#     # virtual environment in the current directory (and activate it)
#     # whenever a new shell session is created.
#     # nenv activate
# fi

# This script provides a new function called nenv that can be used to activtate
# and deactivate virtual environments. A virtual environment is any directory
# that contains a node_modules directory within it. To activate a virtual
# environment, simply cd into it and call the 'nenv activate' command. This
# will check the current directory for a node_modules directory and place the
# bin folder within into the current PATH variable. To return the PATH variable
# back to its original state simply call the 'nenv deactivate' command.

# In addition to altering the PATH variable, nenv also supports setup and
# teardown functionality as well. if a .activate file is found in the directory,
# it will source it when the virtual environment is activated. Likewise, if a
# .deactivate file is found, it will source it upon deactivation. These files
# allow you to do extra setup/teardown to your environment as needed.
#
# Created by Christopher Roach <croach@madebyglitch.com>


_nenv_help() {
    echo
    echo "Node Virtual Environment Manager"
    echo
    echo "Usage:"
    echo "    nenv help             Show this message"
    echo "    nenv activate         Activate the virtual environment in the current directory"
    echo "    nenv deactivate       Deactivate the current virtual environment"
    echo "    nenv home             Change directory to the current virtual environement's directory"
    echo "    nenv ls               Lists the executables registered with the current environment"
    echo
}

# Checks if the current directory is a subdirectory of the current virtual
# environment's main directory.
_nenv_subdirectory() {
    local child="$PWD"
    local parent="$NENV_HOME"
    if [[ "${child##${parent}}" != "$child" ]]; then
        return 0
    else
        return 1
    fi
}

# Activates a new environment
_nenv_activate() {
	# Exit the function if npm isn't installed
	if ! npm -v >/dev/null 2>&1; then
		return 1
	fi

    # Check if the directory we've cd'ed into is a node environment directory
    # (i.e., it contains a node_modules folder) before trying to activate it
    if [ -d "node_modules" ]; then

        # Save the old PATH variable so we can revert back to it when we leave
        # the environment
        export _OLD_PATH="$PATH"

        # An environment is essentially nothing more than an environment
        # variable (NENV_HOME) pointing the parent directory of our node
        # environment. Create the variable and point it to $PWD.
        export NENV_HOME="$PWD"

        # Add the bin folder for all local NPM installs to the PATH
        export PATH="$(npm bin):$PATH"

        # Update the prompt to show that we are in a virtual environment
        export _OLD_PS1="$PS1"
        export PS1="($(basename "$NENV_HOME"))$PS1"

        # If an activation script exists, execute it
        if [ -e ".activate" ]; then
            source .activate
        fi
    fi
}

# Deactivates the current environment
_nenv_deactivate() {
    # Make sure that an environment does exist before we try to deactivate it
    if [ -n "$NENV_HOME" ]; then

        # Run the deactivation script if it exists
        if [[ -e "$NENV_HOME/.deactivate" ]]; then
            source "$NENV_HOME/.deactivate"
        fi

        # Revert back to the original PATH
        export PATH="$_OLD_PATH"

        # Revert the prompt
        export PS1="$_OLD_PS1"

        # Destroy the environment
        unset NENV_HOME
        unset _OLD_PATH
        unset _OLD_PS1
    fi
}

# Lists the executable files registered with the current virtual environment
_nenv_list_executables() {
    # Only run if there is a currently active virtual environment
    if [ -n "$NENV_HOME" ]; then
        for f in $(npm bin)/*; do
            echo "$(basename $f)"
        done
    fi
}

# This function is meant to replace the builtin 'cd' function. Using this will
# make sure that virtual environments are automatically activated and
# deactivated as you cd into and out of them. Not everyone likes the idea of
# aliasing builtin functions to custom functions though, so I've intentionally
# left this step out. If, however, you'd like to have this functionality,
# simply add the following line to your .bashrc or .zshrc script right after
# you source this file:
#
# alias cd="env_cd"
#
# env_cd() {
#     builtin cd "$@" && deactivate_env && activate_env
# }
nenv_cd() {
    builtin cd "$@"

    # Make sure that an environment does exist and that the new
    # directory is not a subdirectory of the environment directory
    if [ -n "$NENV_HOME" ] && ! _nenv_subdirectory; then
        nenv deactivate
    fi

    # Make sure a node environment doesn't already exist before creating a new one.
    if [ -z "$NENV_HOME" ]; then
        nenv activate
    fi
}

nenv() {
    if [ $# -lt 1 ]; then
        nenv help
        return
    fi

    case $1 in
        "help" )
            _nenv_help
            ;;
        "activate" )
            _nenv_activate
            ;;
        "deactivate" )
            _nenv_deactivate
            ;;
        "home" )
            builtin cd "$NENV_HOME"
            ;;
        "ls" )
            _nenv_list_executables
            ;;
        * )
            nenv help
            ;;
    esac
}


# Setup bash and zsh command completion
_nenv_command_completion() {
    local cur
    local commands="help home activate deactivate ls"

    cur="${COMP_WORDS[COMP_CWORD]}"

    # An array storing the possible completions
    COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )

    return 0
}

# complete is a bash builtin, but recent versions of ZSH come with a function
# called bashcompinit that will create the complete function in ZSH. If the
# user is in ZSH, load and run bashcompinit before calling the complete.
if [[ -n ${ZSH_VERSION-} ]]; then
    autoload -U +X bashcompinit && bashcompinit
fi
complete -o default -o nospace -F _nenv_command_completion nenv
