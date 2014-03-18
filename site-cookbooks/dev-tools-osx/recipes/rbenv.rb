#
# Cookbook Name:: dev-tools-osx
# Recipe:: rbenv
#
include_recipe "dev-tools-osx::oh-my-zsh"

target    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{target}"
zshrc     = "#{homepath}/.zshrc"
rbenv     = "#{homepath}/.rbenv"

git rbenv do
  user  target
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
end

script 'install rbenv' do
  not_if %![ -n "`cat #{zshrc} | egrep 'rbenv init'`" ]!
  user  target
  cwd   homepath
  interpreter "zsh"
  flags '-ex'
  code <<-EOH
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> #{zshrc}
    echo 'eval "$(rbenv init -)"' >> #{zshrc}
  EOH
end
