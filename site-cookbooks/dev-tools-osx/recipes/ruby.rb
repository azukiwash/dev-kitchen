#
# Cookbook Name:: dev-tools-osx
# Recipe:: ruby
#
include_recipe "dev-tools-osx::rbenv"

target    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{target}"
zshrc     = "#{homepath}/.zshrc"
rbenv     = "#{homepath}/.rbenv"

version   = node["dev-tools-osx"]["ruby"]["version"]

rbenvsh   = "#{homepath}/rbenv.sh"

script "mkdir plugins" do
  not_if "[ -e #{rbenv}/plugins ]"
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    mkdir -p #{rbenv}/plugins
  EOH
end

git "#{rbenv}/plugins/ruby-build" do
  user  target
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :sync
end

script "install ruby#{version}" do
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    echo 'export RBENV_ROOT="#{homepath}/.rbenv"'    > #{rbenvsh}
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"'  >> #{rbenvsh}
    echo 'eval "$(rbenv init -)"'               >> #{rbenvsh}

    source #{rbenvsh}

    if [ -z "`rbenv versions | egrep '^(  |\\* )#{version}( |$)'`" ]; then
      rbenv install #{version}
      rbenv global  #{version}
    fi

    rbenv rehash

    if [ -z "`gem list | cut -d' ' -f1 | awk '/^bundler$/{print $0}'`" ]; then
      gem install bundler
    fi

    rm #{rbenvsh}
  EOH
end
