#
# Cookbook Name:: dev-tools
# Recipe:: default
#
include_recipe "git"
include_recipe "zsh"

%w[
    dstat
    sl
    figlet
    boxes
    cowsay
    fortune
    nmap
    colordiff
    ngrep
    vim
    tree
    unzip
    curl
    tmux
].each do |pkg|
  package pkg do
    action :upgrade
  end
end

# for build rbenv
case node[:platform]
when "redhat", "centos", "amazon"
  %w[
    gcc-c++
    glibc-headers
    openssl-devel
    readline
    libyaml-devel
    readline-devel
    zlib
    zlib-devel
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
when "ubuntu"
  %w[
    autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    libreadline6
    libreadline6-dev
    zlib1g
    zlib1g-dev
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
end

# for build pyenv
case node[:platform]
when "redhat", "centos", "amazon"
  %w[
    zlib-devel
    bzip2
    bzip2-devel
    readline-devel
    sqlite
    sqlite-devel
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
when "ubuntu"
  %w[
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
end


package "netcat" do
  case node[:platform]
  when "redhat", "centos", "amazon"
    package_name "nc"
  when "ubuntu"
    package_name "netcat"
  end
  action :install
end

chef_gem 'unix-crypt'

require 'unix_crypt'
SALT_CHARSET = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

data_ids = data_bag('users')
data_ids.each_with_index do |id,idx|
  salt = (0..7).inject(""){|s,i| s << SALT_CHARSET[rand 64]}
  u = data_bag_item('users', id)
  user u['id'] do
    comment  u['comment']
    uid      800+idx
    shell    u['shell']
    home     "/home/#{u['id']}"
    supports :manage_home => true
    password UnixCrypt::SHA512.build("#{u['id']}zzz",salt)
    password u['password']
    action   [:create]
  end
  group u['main_group'] do
    action :modify
    gid     800+idx
    members u['id']
    append true
  end
  # files/default/cows.zip
  cookbook_file "/home/#{u['id']}/cows.zip" do
    source "cows.zip"
    mode "0644"
  end
  script 'unzip cows' do
    user  u['id']
    group u['id']
    cwd   "/home/#{u['id']}"
    interpreter "bash"
    flags '-ex'
    code <<-EOH
      HOME=/home/#{u['id']}
      unzip -o /home/#{u['id']}/cows.zip
    EOH
  end
end
