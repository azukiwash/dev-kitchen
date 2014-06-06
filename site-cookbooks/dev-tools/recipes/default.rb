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
    tmux
].each do |pkg|
  package pkg do
    action :upgrade
  end
end

# for build rbenv
case node[:platform]
when "centos"
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
when "centos"
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
