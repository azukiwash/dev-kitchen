#
# Cookbook Name:: dev-tools-osx
# Recipe:: gradle
#

osxuser    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{osxuser}"
zshrc     = "#{homepath}/.zshrc"
bash_profile = "#{homepath}/.bash_profile"

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
  not_if %![ -n "`cat #{bash_profile} | egrep 'export GRADLE_HOME'`" ] && [ -n "`cat #{zshrc} | egrep 'export GRADLE_HOME'`" ]!
  user  osxuser
  cwd   homepath
  interpreter "bash"
  flags '-ex'
  code <<-EOH
    HOME=#{homepath}
    unzip /tmp/#{arc}
    mv #{extractdir} #{target}

    echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{bash_profile}
    echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{bash_profile}
    echo 'export GRADLE_HOME="$HOME/.gradle"' >> #{zshrc}
    echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> #{zshrc}
  EOH
end
