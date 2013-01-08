define celery::service (
    $app_dir,
    $user = 'celery',
    $command = undef,
    $workers = '4',
    $python = '/usr/bin/python',
    $log_level = 'INFO',
    $args = ''
) {
    include supervisord

    if $user == 'celery' {
        include celery::user
    }

    if $command {
      $celery_command = $command
    }
    else {
      $celery_command = "${python} ${app_dir}/manage.py celeryd --loglevel=${log_level} -c ${workers} ${args}"
    }

    $celery_name = $name

    supervisord::program {
        "celeryd-${celery_name}":
            command => $celery_command,
            cwd     => $app_dir,
            user    => $user;
    }

}
