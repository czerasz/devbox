class boxes::base {
  $version = "0.0.1"
  
  #Create the "vagrant" user
  #this is required for the rvm module
  user {"vagrant":
    comment => "Created by Puppet",
  }
  group { "vagrant":
    require => User["vagrant"]
  }

  file {"/etc/motd":
    content => template("boxes/etc/motd.erb"),
    ensure => file,
    replace => true,
  }

	class after::system::update {
		notify {"Start system configuration after system update": }

    #install terminal helpers
    package {"tree":
      ensure => present,
    }

    #install vim
    package {"vim":
      ensure => present,
    }
    
    #install git
    package {["git-core", "git-doc"]:
      ensure => present,
    }

    #install curl
    package {["curl"]:
      ensure => present,
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
    
    #-->BEGIN install mySQL
    #helper:
    # - https://github.com/geopcgeo/LAMP
    # - https://github.com/puppetlabs/puppetlabs-mysql
    #-->END install mySQL

    #-->BEGIN install rvm
    #from module: https://github.com/jfryman/puppet-rvm
    include rvm
    rvm::define::user {"vagrant": }
    rvm::define::version { 'ruby-1.9.3':
      ensure => present,
    }
    rvm::define::gem {"bundler":
      ensure => present,
      ruby_version => "ruby-1.9.3",
    }
    #-->END install rvm

  }#end class after::system::update

  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    before => Notify["Start system update"],
  }
  notify { "Start system update": }

  class { "after::system::update":
    subscribe => Exec["apt-get update"],
  }
}
