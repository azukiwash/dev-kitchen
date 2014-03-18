#
# Cookbook Name:: dev-tools-osx
# Recipe:: oh-my-zsh
#

target = node["dev-tools-osx"]["os"]["user"]
homepath = "/Users/#{target}"
zshrc = "#{homepath}/.zshrc"
oh_my_zsh = "#{homepath}/.oh-my-zsh"
autojump  = "#{homepath}/.autojump"

git oh_my_zsh do
  user  target
  repository "git://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :sync
end

template zshrc do
  not_if %![ -n "`head -1 #{zshrc} | egrep 'Path to your oh-my-zsh configuration'`" ]!
  source 'zshrc.erb'
  owner target
  mode '644'
end

template "#{oh_my_zsh}/custom/custom_aliases.zsh" do
  source 'custom_aliases.zsh.erb'
  owner target
  mode '644'
end
template "#{oh_my_zsh}/custom/custom_history.zsh" do
  source 'custom_history.zsh.erb'
  owner target
  mode '644'
end

git "/tmp/autojump" do
  user  target
  repository "git://github.com/joelthelion/autojump.git"
  reference "master"
  action :sync
end
script 'install autojump' do
  not_if %![ -e #{autojump} ] && [ -n "`cat #{zshrc} | egrep 'autojump.*source.*autojump'`" ]!
  user  target
  cwd   "/tmp"
  interpreter "bash"
  flags '-ex'
  code <<-EOH
    HOME=#{homepath}
    cd /tmp/autojump
    ./install.py --destdir #{autojump}

    echo "[[ -s #{autojump}/etc/profile.d/autojump.sh ]] && source #{autojump}/etc/profile.d/autojump.sh" >> #{zshrc}
    echo "autoload -U compinit && compinit -u" >> #{zshrc}
  EOH
end
