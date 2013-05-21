# mozwebsyslogger
class mozwebsyslogger(
    $device = '/dev/xvdf1',
    $tls = false,
    $ca_cert_content = undef,
    $server_cert_content = undef,
    $server_key_content = undef

){
    include rsyslog

    if $tls {
        $inputname = 'tlsin'
        class {
            'rsyslog::tlsserver':
              ca_cert_content     => $ca_cert_content,
              server_cert_content => $server_cert_content,
              server_key_content  => $server_key_content,
        }
    }
    else {
        $inputname = 'imudp'
        include rsyslog::udpserver
    }

    mount {
        '/var/log/syslogs':
            ensure  => 'mounted',
            device  => $device,
            fstype  => 'ext4',
            options => 'defaults',
            atboot  => true,
            require => File['/var/log/syslogs'];
    }

    file {
        '/var/log/syslogs':
            ensure  => directory,
            mode    => '0755',
    }

    file {
          [
            '/var/log/syslogs/apps',
            '/var/log/syslogs/hosts'
          ]:
            ensure  => directory,
            mode    => '0755',
            require => Mount['/var/log/syslogs'];
    }

    rsyslog::config {
        'websyslogger':
            require => [
                        File['/var/log/syslogs/hosts'],
                        File['/var/log/syslogs/apps']],
            content => template('mozwebsyslogger/syslog.conf');
    }
}
