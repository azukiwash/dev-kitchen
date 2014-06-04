#
# Cookbook Name:: dev-tools-osx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# before you cook you have to do things below (in target host)
# * install newlist XCode
# * xcode-select --install
# * open XCode and agree to the Xcode/iOS license
# * change system configuration to arrow login(ssh) from remotehosts
# * echo "$(whoami)        ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers
include_recipe "homebrew"
include_recipe "dmg"

%w[
    git
    hub
    zsh
    vim
    wget
    curl
    netcat
    ngrep
    nmap
    xz
    binutils
    findutils
    coreutils
    gawk
    gnu-sed
    gnu-tar
    colordiff
    sl
    htop-osx
    pstree
    tree
    readline
    openssl
    osxutils
    pv
    ssldump
    sslscan
    task-spooler
].each do |pkg|
  package pkg do
    action :install
  end
end

# install cask(package manager for mac gui applications)
homebrew_tap 'caskroom/cask'
package 'brew-cask' do
  action :install
end

# install apps
applist = %w[
    google-chrome
    iterm2
    intellij-idea-ce
    dropbox
    gimp
    vagrant
    virtualbox
    caffeine
    google-japanese-ime
    java
    kobito
    skitch
    sourcetree
    the-unarchiver
    onepassword
]
applist.each do |app|
  script "cask install #{app}" do
    not_if %!brew cask list #{app}!
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      brew cask install #{app}
    EOH
  end
end

# install other apps(not using cask)
## macvim_kaoriya
dmg_package 'MacVim' do
  volumes_dir 'MacVim-KaoriYa'
  source   'https://github.com/splhack/macvim/releases/download/20140107/macvim-kaoriya-20140107.dmg'
  checksum '0a87ec0cb28e3b40eec6deb90e9e41ba44937f80de0c154cf80865414a6900b3'
  action   :install
end

# modify files in /etc
bash '/etc/paths' do
  not_if %![ $(head -1 /etc/paths) = '/usr/local/bin' ]!
  flags '-ex'
  code <<-EOH
    cat /etc/paths | sed '$d' | gsed '1i \\/usr\\/local\\/bin' > /etc/paths.new
    mv /etc/paths.new /etc/paths
  EOH
end
bash '/etc/shells' do
  not_if %!cat /etc/shells | egrep '/usr/local/bin/zsh'!
  flags '-ex'
  code <<-EOH
    echo '/usr/local/bin/zsh' >> /etc/shells
  EOH
end

target = node["dev-tools-osx"]["os"]["user"]
homepath = "/Users/#{target}"
zshrc = "#{homepath}/.zshrc"

bash 'chsh to /usr/local/bin/zsh' do
#  not_if %![ "$(echo $SHELL)" = '/usr/local/bin/zsh' ]!
  not_if %![ "$(dscl . read /Users/#{target} UserShell | cut -d' ' -f2)" = '/usr/local/bin/zsh' ]!
  flags '-ex'
  code <<-EOH
    chsh -s /usr/local/bin/zsh #{target}
  EOH
end

include_recipe "dev-tools-osx::oh-my-zsh"

[
  'export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"',
  'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"',
  'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"',
  'export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"',
  'export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"',
  'export JAVA_HOME=$(/usr/libexec/java_home)',
  'export PATH="$JAVA_HOME/bin:$PATH"',
  'export PATH="$PATH:/Applications/MacVim.app/Contents/MacOS"',
  'export LANG="ja_JP.UTF-8"',
  'export LC_ALL="ja_JP.UTF-8"',
  'alias find=gfind',
  'alias xargs=gxargs',
  'alias be="bundle exec"'
].each do |path|
  bash "add PATH to #{zshrc}" do
    not_if %!cat #{zshrc} | grep '#{path}'!
    flags '-ex'
    code <<-EOH
      echo '#{path}' >> #{zshrc}
    EOH
  end
end

# vim config
bash 'install vim pathogen' do
  not_if %![ -e "#{homepath}/.vim/autoload" ] && [ -e "#{homepath}/.vim/bundle" ]!
  flags '-ex'
  code <<-EOH
    mkdir -p #{homepath}/.vim/autoload #{homepath}/.vim/bundle
    curl -Sso #{homepath}/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
    cd #{homepath}/.vim/bundle
    git clone git://github.com/altercation/vim-colors-solarized.git
  EOH
end
template "#{homepath}/.vimrc" do
  source 'vimrc.erb'
  owner target
  mode '644'
end
template "#{homepath}/.gvimrc" do
  source 'gvimrc.erb'
  owner target
  mode '644'
end

# git config
# TODO:
# git config --global user.email ""
# git config --global user.name  ""
bash 'setup git config' do
  not_if %![ -e "#{homepath}/.gitconfig" ]!
  flags '-ex'
  code <<-EOH
    git config --global color.ui auto
    git config --global alias.co "checkout"
    git config --global alias.ci "commit"
    git config --global alias.st "status"
    git config --global core.excludesfile "~/.gitignore"
  EOH
end
template "#{homepath}/.gitignore" do
  source 'gitignore.erb'
  owner target
  mode '644'
end

# install quicklook
bash 'install QLColorCode.qlgenerator' do
  not_if %![ -e "#{homepath}/Library/QuickLook/QLColorCode.qlgenerator" ]!
  flags '-ex'
  code <<-EOH
    rm -rf #{homepath}/Downloads/QLColorCode-extra
    cd #{homepath}/Downloads
    git clone https://github.com/BrianGilbert/QLColorCode-extra.git
    cd QLColorCode-extra
    mv QLColorCode.qlgenerator #{homepath}/Library/QuickLook/
    qlmanage -r
  EOH
end

# install fonts
## ricty
homebrew_tap 'sanemat/font'
package 'ricty' do
  action :install
end
bash 'install ricty' do
  not_if %!fc-list | grep Ricty!
  flags '-ex'
  code <<-EOH
    cp -f /usr/local/share/fonts/Ricty*.ttf #{homepath}/Library/Fonts/
    fc-cache -vf
  EOH
end

## ゆたぽん（コーディング）
remote_file "#{homepath}/Downloads/yutapon_coding_081.zip" do
  source "http://net2.system.to/pc/cgi-bin/download.cgi?file=yutapon_coding_081.zip"
  mode "0644"
end
bash 'install yutapon' do
  not_if %![ -e "#{homepath}/Library/Fonts/yutapon_coding_081.ttc" ]!
  flags '-ex'
  code <<-EOH
    cd #{homepath}/Downloads
    unzip -o #{homepath}/Downloads/yutapon_coding_081.zip
    cp -f #{homepath}/Downloads/yutapon_coding_081.ttc #{homepath}/Library/Fonts/
    fc-cache -vf
  EOH
end
