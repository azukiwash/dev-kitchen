#
# Cookbook Name:: dev-tools
# Recipe:: ruby
#
include_recipe "dev-tools::rbenv"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username  = u['id']
  groupname = u['main_group']
  home      = "/home/#{username}"
  rbenv     = "#{home}/.rbenv"
  version   = node.default.ruby.version
  prefix    = "p0"
  rbenvsh   = "#{home}/rbenv.sh"
  zshrc     = "#{home}/.zshrc"

  script "mkdir plugins" do
    not_if "[ -e #{rbenv}/plugins ]"
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      mkdir -p #{rbenv}/plugins
    EOH
  end

  git "#{rbenv}/plugins/ruby-build" do
    user  username
    group groupname
    repository "git://github.com/sstephenson/ruby-build.git"
    reference "master"
    action :sync
  end

  script "install ruby#{version}" do
    user  username
    group groupname
    cwd   home
    interpreter "zsh"
    flags '-ex'
    code <<-EOH
      echo 'export RBENV_ROOT=#{home}/.rbenv'      > #{rbenvsh}
      echo 'export PATH="$RBENV_ROOT/bin:$PATH"'  >> #{rbenvsh}
      echo 'eval "$(rbenv init -)"'               >> #{rbenvsh}

      source #{rbenvsh}

      if [ "`ruby -v | cut -d' ' -f2`" != "#{version}#{prefix}" ] ; then
        rbenv install #{version}
        rbenv global  #{version}
      fi

      if [ "`gem list | awk '/bundler/{print $1}'`" != "bundler" ] ; then
        gem install bundler
      fi

      rm #{rbenvsh}
    EOH
  end
end
