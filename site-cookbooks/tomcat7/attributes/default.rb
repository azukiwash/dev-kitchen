tomcatVersion  = "7.0.52"
tomcatTarget   = "/usr/local/lib"
tomcatBasename = "apache-tomcat-#{tomcatVersion}"

set[:tomcat7][:version]  = "#{tomcatVersion}"
set[:tomcat7][:basename] = "#{tomcatBasename}"
set[:tomcat7][:url]      = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcatVersion}/bin/"
set[:tomcat7][:archive]  = "#{tomcatBasename}.tar.gz"
set[:tomcat7][:checksum] = "f5f3c2c8f9946bf24445d2da14b3c2b8dc848622ef07c3cda14f486435d27fb0"

set[:tomcat7][:target] = "#{tomcatTarget}"
set[:tomcat7][:user]   = "tomcat"
set[:tomcat7][:group]  = "tomcat"

set[:tomcat7][:jsvcversion]  = "1.0.15"

set[:tomcat7][:port]     = 8080
set[:tomcat7][:ssl_port] = 8443
set[:tomcat7][:ajp_port] = 8009
set[:tomcat7][:java_options] = " -Xmx128M -Dajva.awt.headless=true"
set[:tomcat7][:use_security_manager] = "no"

set[:tomcat7][:home] = "#{tomcatTarget}/tomcat"
set[:tomcat7][:base] = "#{tomcatTarget}/tomcat"
set[:tomcat7][:config_dir] = "#{tomcatTarget}/tomcat/conf"
set[:tomcat7][:log_dir] = "#{tomcatTarget}/tomcat/logs"

