#
# Cookbook Name:: dev-tools
# Recipe:: foobar
#

username  = 'chef'
home      = "/home/#{username}"
zshrc     = "#{home}/.zshrc"
bash_profile = "#{home}/.bash_profile"

# bash 'test_script' do
#   flags '-ex'
#   code <<-EOH
#     id  > /tmp/chef_id.txt
#     env  > /tmp/chef_env.txt
#   EOH
# end

# bash 'test_script' do
#   flags '-ex'
#   code <<-EOH
#     sudo su - #{username} -c 'source #{zshrc}; id  > chef_id.txt'
#     sudo su - #{username} -c 'source #{zshrc}; env  > chef_env.txt'
#   EOH
# end

# script 'test_script' do
#   user username
#   cwd home
#   interpreter 'zsh'
#   environment 'HOME' => home
#   flags '-ex'
#   code <<-EOH
#     SHELL=`which zsh`
#     source #{zshrc}
#     id  > chef_id.txt
#     env > chef_env.txt
#   EOH
# end
