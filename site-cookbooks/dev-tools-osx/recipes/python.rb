#
# Cookbook Name:: dev-tools-osx
# Recipe:: python
#
include_recipe "dev-tools-osx::pyenv"

target    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{target}"
zshrc     = "#{homepath}/.zshrc"
pyenv     = "#{homepath}/.pyenv"

versiontwo   = node["dev-tools-osx"]["python"]["versiontwo"]
versionthree = node["dev-tools-osx"]["python"]["versionthree"]

pyenvsh      = "#{homepath}/pyenv.sh"

script "mkdir plugins" do
  not_if "[ -e #{pyenv}/plugins ]"
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    mkdir -p #{pyenv}/plugins
  EOH
end

git "#{pyenv}/plugins/pyenv-virtualenv" do
  user  target
  repository "git://github.com/yyuu/pyenv-virtualenv.git"
  reference "master"
  action :sync
end

script "install python" do
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    echo 'export PYENV_ROOT="#{homepath}/.pyenv"'   > #{pyenvsh}
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> #{pyenvsh}
    echo 'eval "$(pyenv init -)"'              >> #{pyenvsh}

    source #{pyenvsh}

    if [ -z "`pyenv versions | egrep '^(  |\\* )#{versiontwo}( |$)'`" ]; then
      pyenv install #{versiontwo}
      pyenv global  #{versiontwo}
      curl -kL https://raw.github.com/pypa/pip/master/contrib/get-pip.py | pyenv exec python
    fi

    if [ -z "`pyenv versions | egrep '^(  |\\* )#{versionthree}( |$)'`" ]; then
      pyenv install #{versionthree}
    fi

    if [ -z "`pyenv version | egrep '^#{versionthree}$'`" ] ; then
      pyenv global  #{versionthree}
    fi

    rm #{pyenvsh}
  EOH
end
