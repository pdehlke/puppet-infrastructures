define pegsuser($uid, $gid, $groups, $comment, $home, $profiles, 
				$roles, $auths, $shell, $type, $password){
	user { $name:
	  uid => $uid, gid => $gid, groups => $groups, comment => $comment, home => $home,
	  profiles => $profiles, roles => $roles, auths => $auths,
	  shell => $shell, password => $password, managehome => "true"
   	}
	file { "$home":
	  ensure => directory, owner => $name, group => $gid,
   	}
}

class users {
  @pegsuser {"pde": uid => "666", gid => "staff", groups => "admin", comment => "Pete Ehlke",
  home => "/home/pde", profiles => "Primary Administrator",
  auths => "solaris.smf.manage.bind", shell => "/bin/bash", roles => "root", type => "architect",
  password => "\$5\$6ldDzzIn\$OlRVSQhdYl.a8vrmS16CgdOQ1WHSg6.HdkdUnM5Voa4"
  }
  @pegsuser {"tkieschn": uid => "667", gid => "staff", groups => "admin", comment => "Tim Kieshcnick",
  home => "/home/tkieschn", profiles => "Primary Administrator",
  auths => "solaris.smf.manage.bind", shell => "/bin/bash", roles => "root", type => "architect",
  password => "\$5\$6ldDzzIn\$OlRVSQhdYl.a8vrmS16CgdOQ1WHSg6.HdkdUnM5Voa4"
  }
  @pegsuser {"tcrutchf": uid => 668, gid => staff, groups => "", comment => "Tommy Crutchfield",
  home => "/home/tcrutchf", profiles => "Primary Administrator",
  auths => "", shell => "/bin/bash", roles => root, type => "developer",
  password => ""
  }
}

class architects {
  include users
  Pegsuser <| type == "architect" |>
}

class developers {
  include users
  Pegsuser <| type == "developer" |>
}
