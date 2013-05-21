# nginx class
class nginx(
    $nx_user = 'nginx',
    $version = 'present'
){
    package {
        'nginx':
            ensure  => $version;
    }

    service {
        'nginx':
            ensure     => running,
            require    => Package['nginx'],
            enable     => true,
            restart    => '/etc/init.d/nginx restart',
            status     => '/etc/init.d/nginx status',
            hasstatus  => true,
            hasrestart => true;
    }

    file {
        [
          '/etc/nginx/',
          '/etc/nginx/conf.d/',
          '/etc/nginx/managed/'
        ]:
            ensure  => directory,
            notify  => Service['nginx'],
            force   => true,
            recurse => true,
            purge   => true;

        '/var/log/nginx':
            ensure  => directory,
            require => Package[nginx],
            owner   => $nx_user,
            group   => 'users',
            mode    => '0750';

        '/etc/nginx/nginx.conf':
            before  => Service[nginx],
            content => template('nginx/nginx.conf');

        '/etc/nginx/conf.d/managed.conf':
            before  => Service[nginx],
            content => "include managed/*.conf;\n";

        '/etc/nginx/mime.types':
            source => 'puppet:///modules/nginx/mime.types';

        '/etc/sysconfig/nginx':
            require => Package['nginx'],
            mode    => '0644',
            content => template('nginx/sysconfig/nginx');

        '/etc/logrotate.d/nginx':
            require => Package[nginx],
            owner   => $nx_user,
            group   => root,
            mode    => '0644',
            content => template('nginx/logrotate.conf');

        '/etc/init.d/nginx':
            require => Package[nginx],
            before  => Service[nginx],
            owner   => root,
            group   => root,
            mode    => '0755',
            source  => 'puppet:///modules/nginx/etc-init.d/nginx';
    }
}
