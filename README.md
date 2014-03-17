# Virtual Environment Manager for Node

nenv is a simple virtual environment manager for Node. In short, it adds
exectuables for locally installed node modules to the current PATH so
they are readily avaialable for execution. Additionally, it calls setup
and teardown scripts for the environment, if they exist, allowing for
further modification of the virtual environment.

### Installation

#### Install script

To install, run the following line if you use curl:

```
curl https://raw.github.com/croach/nenv/master/install.sh | sh
```

or this line if you use wget:

```
wget -qO- https://raw.github.com/croach/nenv/master/install.sh | sh
```

> NOTE: The script will clone this repository (or curl the nenv.sh file) into 
~/.nenv and add a few lines to source the file into your .zshrc, .bashrc, or 
.profile file depending on which it finds first. If `nenv` does not work for
you after you install it, make sure the source lines are in the correct file.

#### Manual install 

To install nenv, if you have git installed, just clone this repository.

```bash
git clone https://github.com/croach/nenv.git ~/.nenv
```

Otherwise, you'll need to create the directory, and copy the nenv.sh file into it.

```bash
mkdir ~/.nenv && curl -O https://raw.githubusercontent.com/croach/nenv/master/nenv.sh
```

To activate nenv, you just need to source the nenv.sh file. To do this
automatically everytime you begin a new shell session, copy the following
into your .bashrc or .zshrc file.

```bash
if [[ -f "$HOME/.nenv/nenv.sh" ]]; then
    source "$HOME/.nenv/nenv.sh"

    # Uncomment the following line if you want virtual environments
    # activated/deactivted as you cd into/out of them.
    # alias cd="nenv_cd"

    # Uncomment the following line if you want to try to check for a
    # virtual environment in the current directory (and activate it)
    # whenever a new shell session is created.
    # nenv activate
fi
```

If you would like to automatically activate and deactivate virtual envrionments
as you `cd` into them and out of them, just uncomment the `alias cd="nenv_cd"`
line in the code above. Also, if you'd like to activate an environment when
creating a new shell session, just uncomment the `nenv actiavate` line as well.

### Usage

A virtual environment is any directory that contains a node_modules directory
within it. To activate a virtual environment, simply cd into it and call the
'activate virtual environment' command.

```bash
cd /path/to/virtual/env
nenv activate
```

To see the list of executables available in the current envrionment, call the
'list executables' command.

```
nenv ls
```

This will check the current directory for a node_modules directory and, if
one is found, it will place the bin folder within onto the current PATH.
To return the PATH variable back to its original state, simply call the
'deactivate virtual environment' command.

```
nenv deactivate
```

To get a list of all available commands along with a simple explanation of
what each does, call the 'help' command or just call `nenv` without a command.

```
nenv help
```

In addition to altering the PATH variable, nenv also supports setup and
teardown functionality as well. if a `.activate` file is found in the directory,
it will source it when the virtual environment is activated. Likewise, if a
`.deactivate` file is found, it will source it upon deactivation. These files
allow you to do extra setup/teardown to your environment as needed.
