maintainer       "Yohei Murakawa"
maintainer_email "ittan.cotton.10metre@gmail.com"
description      "Install DevTools"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
%w{ git zsh java }.each do |cb|
  depends cb
end