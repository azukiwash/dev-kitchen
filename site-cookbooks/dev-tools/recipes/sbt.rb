#
# Cookbook Name:: dev-tools
# Recipe:: sbt
#
include_recipe "java"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username   = u['id']
  groupname  = u['main_group']
  home       = "/home/#{username}"

  script 'install conscript sbt' do
    # not_if do
    #   "which cs"
    #   "which sbt"
    # end
    interpreter "bash"
    user username
    group groupname
    cwd home
    flags '-ex'
    code <<-EOH
      HOME=#{home}
      curl https://raw.github.com/n8han/conscript/master/setup.sh | sh

      echo 'SBT_OPTS="-Xms128M -Xmx128M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=64M"' > #{home}/bin/sbt
      echo 'java $SBT_OPTS -jar #{home}/.conscript/sbt-launch.jar "$@"' >> #{home}/bin/sbt
      chmod u+x #{home}/bin/sbt
    EOH
  end

  script 'install giter8' do
    interpreter "bash"
    user username
    group groupname
    cwd home
    flags '-ex'
    code <<-EOH
      HOME=#{home}
      $HOME/bin/cs n8han/giter8
    EOH
  end
end