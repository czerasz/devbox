class boxes::base {
  $version = "0.0.1"

  file {"/etc/motd":
    content => template("boxes/etc/motd.erb"),
    ensure => file,
    replace => true
  }

	class after::system::update {
		notify {"Start system configuration after system update": }

    #install terminal helpers
    package {"tree":
      ensure => present
    }

    #install vim
    package {"vim":
      ensure => present
    }
    
    #install git
    package {["git-core", "git-doc"]:
      ensure => present
    }

    #-->BEGIN install apache
    #from module: https://github.com/puppetlabs/puppetlabs-apache 
    include apache
    package {"php5": }
    class {"apache::php": }

    exec {"a2ensite default": 
      path => ["/usr/sbin/", "/usr/bin/", "/usr/sbin/", "/bin"],
      notify => Service["apache2"],
      command => "sudo a2ensite default",
    }
    
    Package["php5"] -> Class["apache::php"] -> Exec["a2ensite default"]

    #-->END install apache
    
  }#end class after::system::update

  exec { "apt-get update":
    command => '/usr/bin/apt-get update',
    before => Notify["Start system update"],
  }
  notify { "Start system update": }

  class { "after::system::update":
    subscribe => Exec["apt-get update"]
  }
}
