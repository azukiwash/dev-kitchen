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

  git "#{rbenv}/plugins/ruby-build" do
    user  username
    group groupname
    repository "git://github.com/sstephenson/ruby-build.git"
    reference "master"
    action :sync
  end

  script "install ruby#{version}" do
    not_if %!test "`ruby -v | cut -c 1-10`" = 'ruby #{version}'!
    user  username
    group groupname
    cwd   home
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      echo 'export RBENV_ROOT=#{home}/.rbenv'      > #{home}/rbenv.sh
      echo 'export PATH="$RBENV_ROOT/bin:$PATH"'  >> #{home}/rbenv.sh
      echo 'eval "$(rbenv init -)"'               >> #{home}/rbenv.sh

      source #{home}/rbenv.sh; rbenv install #{version}
      source #{home}/rbenv.sh; rbenv global  #{version}

      rm #{home}/rbenv.sh
    EOH
  end
end
