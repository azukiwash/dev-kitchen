#
# Cookbook Name:: dev-tools
# Recipe:: rbenv
#
include_recipe "dev-tools::oh-my-zsh"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username  = u['id']
  groupname = u['main_group']
  home      = "/home/#{username}"
  rbenv     = "#{home}/.rbenv"
  zshrc     = "#{home}/.zshrc"

  git rbenv do
    user  username
    group groupname
    repository "git://github.com/sstephenson/rbenv.git"
    reference "master"
    action :sync
  end

  script 'install rbenv' do
    not_if %![ -n "`cat #{zshrc} | egrep 'rbenv init'`" ]!
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> #{zshrc}
      echo 'eval "$(rbenv init -)"' >> #{zshrc}
    EOH
  end
end
