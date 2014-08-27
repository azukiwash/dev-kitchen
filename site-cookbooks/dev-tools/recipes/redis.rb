#
# Cookbook Name:: dev-tools
# Recipe:: haskell
#
package "redis" do
  action :upgrade
end
service "redis" do
  action [:enable, :restart]
end