#
# Cookbook Name:: dev-tools-osx
# Recipe:: sbt
#

osxuser    = node["dev-tools-osx"]["os"]["user"]
homepath  = "/Users/#{osxuser}"

script 'install conscript sbt' do
  not_if %![ -e #{homepath}/bin/cs ] && [ -e #{homepath}/bin/sbt ]!
  interpreter "bash"
  user osxuser
  cwd homepath
  flags '-ex'
  code <<-EOH
    HOME=#{homepath}
    curl https://raw.github.com/n8han/conscript/master/setup.sh | sh

    echo 'SBT_OPTS="-Xms128M -Xmx128M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=64M"' > #{homepath}/bin/sbt
    echo 'java $SBT_OPTS -jar #{homepath}/.conscript/sbt-launch.jar "$@"' >> #{homepath}/bin/sbt
    chmod u+x #{homepath}/bin/sbt
  EOH
end

script 'install giter8' do
  not_if %![ -e #{homepath}/bin/g8 ]!
  interpreter "bash"
  user osxuser
  cwd homepath
  flags '-ex'
  code <<-EOH
    HOME=#{homepath}
    $HOME/bin/cs n8han/giter8
  EOH
end
