class func {
	File {
		owner => 'root',
		group => 'root',
		mode => 644,
	}

	Service {
		ensure => running,
		enable => true,
	}

	package { ['func', 'certmaster']:
		ensure => installed,
	}

	service { 'funcd':
		require => Package['func'],
	 }

	service { 'certmaster':
		require => Package['certmaster'],
	}


	file { '/etc/func/minion.conf':
		content => template('func/func/minion.conf'),
		notify => Service['funcd'],
		require => Package['func'],
	}

	file { '/etc/certmaster/minion.conf':
		content => template('func/certmaster/minion.conf'),
		notify => Service['certmaster'],
		require => Package['certmaster'],
	}

	iptables::hole { 'func':
		port => 51234,
	}

	# The overlord
	if $fqdn == $servername {

		file { '/etc/func/overlord.conf':
			content => template('func/func/overlord.conf'),
			notify => Service['funcd'],
			require => Package['func'],
		}

		file { '/etc/certmaster/certmaster.conf':
			content => template('func/certmaster/certmaster.conf'),
			notify => Service['certmaster'],
			require => Package['certmaster'],
		}
		iptables::hole { 'func-overlord':
			port => 51235
		}
	}
}
