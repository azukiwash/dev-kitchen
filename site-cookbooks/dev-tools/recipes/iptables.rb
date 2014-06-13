#
# Cookbook Name:: dev-tools
# Recipe:: iptables
#

case node[:platform]
when "redhat", "centos", "fedora"
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
