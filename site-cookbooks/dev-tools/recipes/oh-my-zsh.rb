#
# Cookbook Name:: dev-tools
# Recipe:: oh-my-zsh
#
include_recipe "git"
include_recipe "zsh"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username  = u['id']
  groupname = u['main_group']
  home      = "/home/#{username}"
  oh_my_zsh = "#{home}/.oh-my-zsh"

  git oh_my_zsh do
    user  username
    group groupname
    repository "git://github.com/robbyrussell/oh-my-zsh.git"
    reference "master"
    action :sync
  end

  template "#{home}/.zshrc" do
    source 'zshrc.erb'
    owner username
    mode '644'
  end
  template "#{home}/.oh-my-zsh/custom/custom_aliases.zsh" do
    source 'custom_aliases.zsh.erb'
    owner username
    mode '644'
  end
  template "#{home}/.oh-my-zsh/custom/custom_history.zsh" do
    source 'custom_history.zsh.erb'
    owner username
    mode '644'
  end

  git "/tmp/autojump" do
    user  username
    group groupname
    repository "git://github.com/joelthelion/autojump.git"
    reference "master"
    action :sync
  end
  script 'install autojump' do
    user  username
    group groupname
    cwd   "/tmp"
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      cd /tmp/autojump
      ./install.py --destdir #{home}/.autojump

      echo "[[ -s #{home}/.autojump/etc/profile.d/autojump.sh ]] && source #{home}/.autojump/etc/profile.d/autojump.sh" >> #{home}/.zshrc
      echo "autoload -U compinit && compinit -u" >> #{home}/.zshrc
    EOH
  end
end