class mozwebnode(
    $cluster,
    $pkghost,
    $pyrepo_server = 'https://pyrepo.addons.mozilla.org/'
){
    include supervisord

    package {
        'git':
            ensure => 'present';
    }

    class {
        'pyrepo':
            server => $pyrepo_server;
        'nginx':
            version => 'present';
    }

    file {
        ['/data',
         "/data/${cluster}",
         "/data/${cluster}/bin"]:
            ensure => 'directory';
    }

    mozdeploy::client {
        $cluster: 
            pkghost => $pkghost;
    }
}
