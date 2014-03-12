#
# Cookbook Name:: dev-tools
# Recipe:: python
#
include_recipe "dev-tools::pyenv"

case node[:platform]
when "centos"
  %w[
    zlib-devel
    bzip2
    bzip2-devel
    readline-devel
    sqlite
    sqlite-devel
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
when "ubuntu"
  %w[
    make
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
end

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username     = u['id']
  groupname    = u['main_group']
  home         = "/home/#{username}"
  pyenv        = "#{home}/.pyenv"
  versiontwo   = node.default.python.versiontwo
  versionthree = node.default.python.versionthree
  pyenvsh      = "#{home}/pyenv.sh"
  zshrc        = "#{home}/.zshrc"

  script "mkdir plugins" do
    not_if "[ -e #{pyenv}/plugins ]"
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      mkdir -p #{pyenv}/plugins
    EOH
  end

  git "#{pyenv}/plugins/pyenv-virtualenv" do
    user  username
    group groupname
    repository "git://github.com/yyuu/pyenv-virtualenv.git"
    reference "master"
    action :sync
  end

  script "install python" do
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      echo 'export PYENV_ROOT="#{home}/.pyenv"'   > #{pyenvsh}
      echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> #{pyenvsh}
      echo 'eval "$(pyenv init -)"'              >> #{pyenvsh}

      source #{pyenvsh}

      if [ -z "`pyenv versions | egrep #{versiontwo}`" ] ; then
        pyenv install #{versiontwo}
        pyenv global  #{versiontwo}
        curl -kL https://raw.github.com/pypa/pip/master/contrib/get-pip.py | pyenv exec python
      fi

      if [ -z "`pyenv versions | egrep #{versionthree}`" ] ; then
        pyenv install #{versionthree}
      fi

      if [ -z "`pyenv version | egrep #{versionthree}`" ] ; then
        pyenv global  #{versionthree}
      fi

      rm #{pyenvsh}
    EOH
  end
end
