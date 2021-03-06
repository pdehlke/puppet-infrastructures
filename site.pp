# /etc/manifest/site.pp is the first file that, by default, the PuppetMaster loads
# if no external tool is used to manage nodes.

# From here everything starts

# define some stages, or everything happens in nondeterministic order.
stage { [apt, hadoop-base, hadoop-main, users]:}                                                               
Stage[apt] -> Stage[users] -> Stage[hadoop-base] -> Stage[hadoop-main]-> Stage[main] 

# Example42 common module has to be explicitely imported
# (contains defines used by other modules that won't autoload)
import "common"


# The definition of nodes, what classes they include and what variables are set for them
# is done, obvisouly, accordin to custom need.
# Here are provided some example42 setups

# 1 - Example42 small site (approx. 1-20 nodes):
# You define NODES, that inherit a basenode 
# Each node can include classes or defines
import "classes/*"
import "example42/small/site.pp"

# 2 - Example42 medium site (approx. 20-400 nodes):
# You can define ZONES (different networks, geographical sites or whatever)
# You define NODES that inherits zones
# Each node should include a ROLE
# A ROLE includes all the classes/defines necessary for a group of servers with the same functionality
# import "example42/medium/site.pp"

# Baselines classes include modules that can be to be applied to all nodes.
import "baselines/*.pp"

# On a medium/big sized infrastructure it makes sense to use roles
# These are classes that include other classes and resources for a specific purpose
# You may include them in your nodes
# In the example42 nodes samples thaa use the general baseline the relevant role
# is automatically included on how you define the $role variable
import "roles/*.pp"

# Set /usr/gnu/bin first so Solaris clients don't break when 3rd party
# stuff is written for gnu utils instead of standard utils.
Exec { path => "/usr/gnu/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin" }
