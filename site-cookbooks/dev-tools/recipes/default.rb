#
# Cookbook Name:: dev-tools
# Recipe:: default
#
include_recipe "git"
include_recipe "zsh"

%w[
    dstat
    sl
    nmap
    colordiff
    ngrep
    screen
    vim
    tree
    unzip
    curl
].each do |pkg|
  package pkg do
    action :upgrade
  end
end

package "netcat" do
  case node[:platform]
  when "centos"
    package_name "nc"
  when "ubuntu"
    package_name "netcat"
  end
  action :install
end

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  user u['id'] do
    comment  u['comment']
    uid      u['uid']
    shell    u['shell']
    home     "/home/#{u['id']}"
    supports :manage_home => true
    password u['password']
    action   [:create]
  end
  group u['main_group'] do
    action :modify
    gid     u['main_gid']
    members u['id']
    append true
  end
end

# iptables
case node[:platform]
when "centos"
  template "/etc/sysconfig/iptables" do
    source "iptables.erb"
    owner "root"
    group "root"
    mode "0600"
  end
  service "iptables" do
    action [:enable, :restart]
  end
when "ubuntu"
  directory "/etc/iptables" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
  template "/etc/iptables/general" do
    source "iptables.erb"
    owner "root"
    group "root"
    mode "0600"
  end
  bash 'setup iptables' do
    flags '-ex'
    code <<-EOH
      /sbin/iptables-restore < /etc/iptables/general
      echo '#!/bin/sh'                              > /etc/network/if-pre-up.d/iptables_start
      echo '/sbin/iptables-restore < /etc/general' >> /etc/network/if-pre-up.d/iptables_start
      echo 'exit 0'                                >> /etc/network/if-pre-up.d/iptables_start
      chmod +x /etc/network/if-pre-up.d/iptables_start
    EOH
  end
end
