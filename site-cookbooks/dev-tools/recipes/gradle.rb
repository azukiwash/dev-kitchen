#
# Cookbook Name:: dev-tools
# Recipe:: gradle
#
include_recipe "java"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  username   = u['id']
  groupname  = u['main_group']
  home       = "/home/#{username}"
  version    = '1.11'
  arc        = "gradle-#{version}-all.zip"
  url        = "http://services.gradle.org/distributions/#{arc}"
  sha256     = "07e58cd960722c419eb0f6a807228e7179bb43bc266f390cde4632abdacdd659"
  extractdir = "gradle-#{version}"
  target     = ".gradle"

  remote_file "/tmp/#{arc}" do
    source url
    mode "0644"
    checksum sha256
  end

  script 'unzip gradle' do
    not_if { File.exist? "#{home}/#{target}" }
    user  username
    group groupname
    cwd   home
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      unzip /tmp/#{arc}
      mv #{extractdir} #{target}
      echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{home}/.bash_profile
      echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{home}/.bash_profile
      echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{home}/.zshrc
      echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{home}/.zshrc
    EOH
  end
end