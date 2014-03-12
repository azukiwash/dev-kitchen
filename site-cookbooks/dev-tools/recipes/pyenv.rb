#
# Cookbook Name:: dev-tools
# Recipe:: pyenv
#
include_recipe "dev-tools::oh-my-zsh"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username  = u['id']
  groupname = u['main_group']
  home      = "/home/#{username}"
  pyenv     = "#{home}/.pyenv"
  zshrc     = "#{home}/.zshrc"

  git pyenv do
    user  username
    group groupname
    repository "git://github.com/yyuu/pyenv.git"
    reference "master"
    action :sync
  end

  script 'install pyenv' do
    not_if %![ -n "`cat #{zshrc} | egrep 'pyenv init'`" ]!
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      echo 'export PYENV_ROOT="$HOME/.pyenv"' >> #{zshrc}
      echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> #{zshrc}
      echo 'eval "$(pyenv init -)"' >> #{zshrc}
    EOH
  end
end
