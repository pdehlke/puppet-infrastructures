class default_node {
  include "default_node::$operatingsystem"	  
}

class default_node::common {
  include architects
  $ntp_servers = [ "ntp.pegs.com", "ntp1.pegs.com" ]
  include ntp
  include "timezone::${operatingsystem}::utc"
}

class default_node::solaris inherits default_node::common {
  package { 
	[ "vim", "screen", "mq41", "git", "subversion",
	"java", "jdk", "jdk64", "glassfishv2" ]:
  	provider => pkg,
  	ensure => present;
  }
}

class default_node::ubuntu inherits default_node::common {
  package {
   	[ "openssh-server", "bzr", "keychain", "vim-puppet", "htop", "screen", 
	"sysstat", "git-core", "tmpreaper", "etckeeper" ] :
	ensure => installed
  }
}
