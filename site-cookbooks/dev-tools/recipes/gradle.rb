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
  bash_profile = "#{home}/.bash_profile"
  zshrc        = "#{home}/.zshrc"

  remote_file "/tmp/#{arc}" do
    source url
    mode "0644"
    checksum sha256
  end

  script 'unzip gradle' do
    not_if %![ -n "`cat #{bash_profile} | egrep 'export GRADLE_HOME'`" ] && [ -n "`cat #{zshrc} | egrep 'export GRADLE_HOME'`" ]!
    user  username
    group groupname
    cwd   home
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      HOME=#{home}
      unzip /tmp/#{arc}
      mv #{extractdir} #{target}

      echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{bash_profile}
      echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{bash_profile}
      echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{zshrc}
      echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{zshrc}
    EOH
  end
end
