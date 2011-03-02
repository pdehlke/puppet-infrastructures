class j2eeapps {

	include "pegasus-j2eeapps"

	file {"/pegs":
	  ensure => directory,
	}

	file {"/pegs/apps":
	  ensure => directory,
	}

	file {"/usr/appserver/config/.aspass":
		owner  => glassfish,
		group  => root,
		mode   => 644,
		source => "puppet://wopr.pegs.com/files/opt/glassfishv3/.aspass"
	}

	package {"glassvishv2":
	  ensure => present,
	  provider => pkg,
	  before => File["/usr/appserver/config/.aspass"];
	}

	Domain {
	    user => "root",
	    asadminuser => "admin",
	    passwordfile => "/usr/appserver/config/.aspass",
	}
	
	Systemproperty {
	    user => "root",
	    asadminuser => "admin",
	    passwordfile => "/usr/appserver/config/.aspass"
	}

	Jdbcconnectionpool {
		ensure => present,
		user => "root",
		asadminuser => "admin",
		passwordfile => "/usr/appserver/config/.aspass",
		datasourceclassname => "com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource",
		resourcetype => "javax.sql.ConnectionPoolDataSource",
	}

	Jdbcresource {
		ensure => present,
		user => "root",
		passwordfile => "/usr/appserver/config/.aspass",
	}
	
	Application {
		ensure => present,
		user => "root",
		passwordfile => "/usr/appserver/config/.aspass",
	}
	
	Jvmoption {
		ensure => present,
		user => "root",
		passwordfile => "/usr/appserver/config/.aspass",
	}
	
	domain {"domain1": ensure => absent; }

	class silo1 inherits j2eeapps{

		file {"/pegs/apps/sysproptest.war":
			owner  => root,
			group  => root,
			mode   => 644,
			ensure => present,
			source => "puppet://wopr.pegs.com/files/apps/sysproptest.war"
		}
		
		domain {
		    "silo1":
			portbase => "4900",
			smf => false,
		    ensure => present,
			require => File["/usr/appserver/config/.aspass"];
		}
		
		systemproperty {
			"search-url":
			portbase => "4900",
			ensure => present,
			value => "http://www.google.com",
			require => Domain["silo1"];
		}
	
		jdbcconnectionpool {
		"MyPool":
			portbase => "4900",
			properties => "password=mYPasS:user=myuser:url=jdbc\:mysql\://host.ex.com\:3306/mydatabase:useUnicode=true:characterEncoding=utf8:characterResultSets=utf:autoReconnect=true:autoReconnectForPools=true",
			require => Domain["silo1"]
		}
	
		jdbcresource {
		"jdbc/MyPool":
			connectionpool => "MyPool",
			require => Jdbcconnectionpool["MyPool"],
			portbase => "4900",
		}
	
		application {
			"sysproptest":
			source => "/pegs/apps/sysproptest.war",
			portbase => "4900",
			require => [File["/pegs/apps/sysproptest.war"], Jdbcconnectionpool["MyPool"]],
			subscribe => [File["/pegs/apps/sysproptest.war"]];
		}
	
		jvmoption {
			["-DjvmRoute=01", "-server", "-XX:+PrintGCDateStamps"]:
			portbase => "4900",
			require => Domain["silo1"]
		}
	}

	class silo2 inherits j2eeapps {

		file {"/pegs/apps/sysproptest.war":
			owner  => root,
			group  => root,
			mode   => 644,
			ensure => present,
			source => "puppet://wopr.pegs.com/files/apps/sysproptest.war"
		}
		
		domain { "silo2":
			portbase => "5000",
			smf => false,
			passwordfile => "/usr/appserver/config/.aspass",
		    ensure => present,
			require => File["/usr/appserver/config/.aspass"];
		}
		
		systemproperty { "search-url":
			portbase => "5000",
			ensure => present,
			value => "http://www.google.com",
			require => Domain["silo2"];
		}
	
		jdbcconnectionpool { "MyPool":
			portbase => "5000",
			properties => "password=mYPasS:user=myuser:url=jdbc\:mysql\://host.ex.com\:3306/mydatabase:useUnicode=true:characterEncoding=utf8:characterResultSets=utf:autoReconnect=true:autoReconnectForPools=true",
			require =>  Domain["silo2"]
		}
	
		jdbcresource { "jdbc/MyPool":
			connectionpool => "MyPool",
			require => [Jdbcconnectionpool["MyPool"]],
			portbase => "5000",
		}
	
		application { "sysproptest":
			source => "/pegs/apps/sysproptest.war",
			portbase => "5000",
			require => [File["/pegs/apps/sysproptest.war"], Jdbcconnectionpool["MyPool"],],
		}
	
		jvmoption { ["-DjvmRoute=01", "-server", "-XX:+PrintGCDateStamps"]:
			portbase => "5000",
			require => Domain["silo2"]
		}
  }
}
