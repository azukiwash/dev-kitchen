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

  git rbenv do
    user  username
    group groupname
    repository "git://github.com/sstephenson/rbenv.git"
    reference "master"
    action :sync
  end

  script 'install rbenv' do
    not_if "which rbenv"
    user  username
    group groupname
    cwd   home
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> #{home}/.zshrc
      echo 'eval "$(rbenv init -)"' >> #{home}/.zshrc
      mkdir -p #{home}/.rbenv/plugins
    EOH
  end
end
