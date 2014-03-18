#
# Cookbook Name:: dev-tools-osx
# Recipe:: pyenv
#
include_recipe "dev-tools-osx::oh-my-zsh"

target    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{target}"
zshrc     = "#{homepath}/.zshrc"
pyenv     = "#{homepath}/.pyenv"

git pyenv do
  user  target
  repository "git://github.com/yyuu/pyenv.git"
  reference "master"
  action :sync
end

script 'install pyenv' do
  not_if %![ -n "`cat #{zshrc} | egrep 'pyenv init'`" ]!
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> #{zshrc}
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> #{zshrc}
    echo 'eval "$(pyenv init -)"' >> #{zshrc}
  EOH
end
