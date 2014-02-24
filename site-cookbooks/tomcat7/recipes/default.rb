#
# Cookbook Name:: tomcat7
# Recipe:: default
#
include_recipe 'java'

tomcatVer      = node["tomcat7"]["version"]
tomcatBasename = node["tomcat7"]["basename"]
tomcatUrl      = node["tomcat7"]["url"]
tomcatArc      = node["tomcat7"]["archive"]

tomcatTarget = node["tomcat7"]["target"]
tomcatUser   = node["tomcat7"]["user"]
tomcatGroup  = node["tomcat7"]["group"]

tomcatHome   = node["tomcat7"]["home"]


remote_file "/tmp/#{tomcatArc}" do
  source "#{tomcatUrl}/#{tomcatArc}"
  mode "0644"
  checksum node["tomcat7"]["checksum"]
end

group "#{tomcatGroup}" do
  action :create
end

user "#{tomcatUser}" do
  comment "Tomcat user"
  gid "#{tomcatGroup}"
  home "#{tomcatHome}"
  shell "/bin/false"
  system true
  action :create
end

directory "#{tomcatTarget}/#{tomcatBasename}" do
  owner "#{tomcatUser}"
  group "#{tomcatGroup}"
  mode "0755"
  action :create
end

execute "tar" do
  user "#{tomcatUser}"
  group "#{tomcatGroup}"
  installation_dir = "#{tomcatTarget}"
  cwd installation_dir
  command "tar xvfz /tmp/#{tomcatArc}"
  action :run
end

link "#{tomcatHome}" do
  to "#{tomcatTarget}/#{tomcatBasename}"
  link_type :symbolic
end

template "#{tomcatTarget}/tomcat/conf/server.xml" do
  source "server.xml.erb"
  owner "#{tomcatUser}"
  group "#{tomcatGroup}"
  mode "0644"
end

script 'make and install jsvc' do
  interpreter "bash"
  user "root"
  group "root"
  cwd "#{tomcatHome}/bin"
  flags '-ex'
  code <<-EOH
    tar xvfz commons-daemon-native.tar.gz
    cd commons-daemon-#{node['tomcat7']['jsvcversion']}-native-src/unix
    /etc/profile.d/jdk.sh
    ./configure
    make
    cp jsvc ../..
    cd ../..
    EOH
  not_if {File.exists?("#{tomcatHome}/bin/jsvc")}
end

template "/etc/init.d/tomcat" do
  source "daemon.sh.erb"
  owner "root"
  group "root"
  mode "0755"
end

execute "daemon" do
  user "root"
  group "root"
  case node["platform"]
  when "debian","ubuntu"
    command "update-rc.d tomcat defaults"
  else
    command "chkconfig --add tomcat"
  end
  action :run
end

service "tomcat" do
  service_name "tomcat"
  action :start
end