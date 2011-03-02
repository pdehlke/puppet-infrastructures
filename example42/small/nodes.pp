# Define here your nodes

# In this example for a small site just define a basenode with general settings 
# and the host nodes that inherit it

node basenode {
    $my_project = "example42"
	$debug = "yes"
	$monitor = "yes"
	$monitor_type = ["nagios", "munin"]
	$monitor_tool = "nagios"
	$backup = "no"
	$firewall = "no"
    $puppet_server = "puppet.pegs.com"

    resolver::conf { "vmware-pegs":                                                     
      domainname => "pegs.com",                                                         
      searchpath => ["pegs.com", "pegsinc.com"],                                        
      nameservers => "172.16.116.2",                                                    
    }                                              
    $smtp_server = "smtp.pegs.com"

# Local root mail is forwarded to $root_email - CHANGE IT!
    $root_email = "peter.ehlke@pegs.com"

    $syslog_server = "172.16.116.133"
    $timezone = "UTC"
    $ntp_server = "ntp.pegs.com"

    $update = "no"   # Auto Update packages (yes|no)
    $munin_server = "172.16.116.133"
    $collectd_server = "172.16.116.133"
	$dashboard_server = "puppet.pegs.com"
	$nrpe_allowed_hosts = "172.16.116.133"
	$nrpe_dont_blame_nrpe = "1"
	$dashboard_monitor_url_pattern = "Puppet"
	$dashboard_monitor_baseurl = "http://puppet.pegs.com:3000/"
}

node hadoop-base inherits basenode {                                                 
	include general
	include default_node
    include developers                                                           
	include architects
    $namenode_host = "client"                                                    
    $namenode_port = "8200"                                                      
    $jobtracker_host = "client"                                                  
    $jobtracker_port = "8201"                                                    
    class {"hadoop::apt": stage => apt}
	class {"hadoop::base": stage => hadoop-base}                                 
}                                                                                

node 'puppet.pegs.com' inherits basenode {

# Access lists for Puppetmaster access (can be an array)
	$puppet_allow = [ "pegs.com" , "*" ]

# Define if you want to use a node tool (with or without external nodes support)
# Possible values are "foreman" or "dashboard". Default is no tool.
    $puppet_nodetool = "dashboard"
# $puppet_nodetool = "foreman"
    $dashboard_db = "mysql"

    $puppet_storeconfigs = "yes"
    $puppet_db = "mysql"
    $puppet_db_server = "localhost"
    $puppet_db_user = "puppet"
    $puppet_db_password = "mys3cr3tp4ss0rd"

# Define if you want to enable external nodes support (you define nodes via the tools' web interface and not in Puppet language)
# Note that if you enable external nodes support you MUST define a $puppet_nodetool
    $puppet_externalnodes = "no"
	include general
	include puppet
	include ssh::auth::keymaster
	include nagios
}

                                                                                 
node 'client' inherits hadoop-base {
  include apache
  include nagios::target
  include tomcat
  class {"hadoop::namenode": stage => hadoop-main}                               
#  class {"hadoop::worker": stage => hadoop-main}                                 
  class {"hadoop::jobtracker": stage => hadoop-main}                             
}                                                             

## PRODUCTION -  Internet Services

# Postfix+Mailscanner+Mailwatch Mail Server
node 'mail.example42.com' inherits basenode {
        $postfix_mysqluser = "postfix"
        $postfix_mysqlpassword = "example42"
        $postfix_mysqlhost = "127.0.0.1"
        $postfix_mysqldbname = "postfix"
        $postfix_mynetworks = $network/$netmask

        $mailwatch_mysqluser = "mailwatch"
        $mailwatch_mysqlpassword = "exampl42"
        $mailwatch_mysqlhost = "127.0.0.1"
        $mailwatch_mysqldbname = "mailscanner"

        $mysql_passwd = "example42"

        include general
        include mysql::example42
        include dovecot::example42
        include clamav::epel
        include spamassassin
        # include mailscanner::example42
        # include mailscanner::postfix::mailwatch
        include postfix::example42
        include squirrelmail

}


# Generic Httpd server
node 'www.example42.com' inherits basenode {
        include general
	include apache
}


# Samba PDC - Ldap backend 
node 'dc.example42.com' inherits basenode {
        $ldap_master = "127.0.0.1"
        $ldap_slave  = "127.0.0.1"
        $ldap_basedn = "dc=example42,dc=com"
        $ldap_rootdn = "cn=Manager,dc=example42,dc=com"
        $ldap_rootpw = "{SSHA}example42tosha"
        $ldap_rootpwclear = "example42"
        $samba_sid        = "S-1-5-21-3645972101-772173552-949487278"
        $samba_workgroup  = "EXAMPLE42"
        $samba_pdc        = "dc.example42.com"
        $mysql_passwd     = "example42"

        include general

        include samba::ldap
}

node 'gw.example42.com' inherits basenode {
        $role = "gateway"
#       $ipforward = "yes"
        $ntop_password = "CHANGE:Password"
        config { sysctl:
                file      => "/etc/sysctl.conf",
                parameter => "net.ipv4.ip_forward",
                value     => "1",
                engine    => "augeas",
        }

        include general
        include apache
        include squid::transparent
        include ntop
        include sarg
}

node 'vpn.example42.com' inherits basenode {
        $role = "vpn"
        $ipforward = "yes"

        include general
        include openvpn::example42
        include rip::example42
}


# Oracle Cluster (RHEL5)
node 'oracle01.example42.com' inherits basenode {
        include minimal
	include oracle
}

node 'oracle02.example42.com' inherits basenode {
        include minimal
	include oracle
}

