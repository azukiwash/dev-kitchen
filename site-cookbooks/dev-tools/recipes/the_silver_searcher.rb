#
# Cookbook Name:: dev-tools
# Recipe:: the_silver_searcher
#
case node[:platform]
when "centos"
  %w[
      gcc
      automake
      pkgconfig
      pcre-devel
      zlib-devel
      xz-devel
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
when "ubuntu"
  %w[
      automake
      pkg-config
      libpcre3-dev
      zlib1g-dev
      liblzma-dev
  ].each do |pkg|
    package pkg do
      action :upgrade
    end
  end
end

git "/tmp/the_silver_searcher" do
  repository "git://github.com/ggreer/the_silver_searcher.git"
  reference "master"
  action :sync
end

script 'install the_silver_searcher' do
  not_if "which ag"
  interpreter "bash"
  flags '-ex'
  code <<-EOH
    cd /tmp/the_silver_searcher
    ./build.sh
    make install
  EOH
end
