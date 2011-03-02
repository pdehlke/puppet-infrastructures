class aptsetup {
	 file {
	    "/etc/apt/sources.list.d/partner.list":
		ensure  => file,
		source  => "puppet://wopr.pegs.com/files/etc/apt/sources.list.d/partner.list",
		owner   => "root",
		group   => "root";
	}
	exec { subscribe-echo:
		command     => "/usr/bin/apt-get -q -q update",
		logoutput   => false,
		refreshonly => true,
		subscribe   => File["/etc/apt/sources.list.d/partner.list"]
	}
	file {
	  "/etc/apt/cloudera.key":
	  ensure  => file,
	  source  => "puppet://wopr.pegs.com/files/etc/apt/cloudera.key",
	  owner   => "root",
	  group   => "root";
	  }
	exec { import-echo:
		command     => "/usr/bin/apt-key add /etc/apt/cloudera.key",
		logoutput   => false,
		refreshonly => true,
		subscribe   => File["/etc/apt/cloudera.key"]
	}

}
