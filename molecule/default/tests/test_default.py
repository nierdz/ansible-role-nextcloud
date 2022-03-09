"""Role testing files using testinfra."""

def test_hosts_file(host):
    f = host.file("/etc/hosts")
    assert f.exists
    assert f.user == "root"
    assert f.group == "root"

def test_nginx_running_and_enabled(host):
    nginx = host.service("nginx")
    assert nginx.is_running
    assert nginx.is_enabled

def test_php_running_and_enabled(host):
    php = host.service("php7.4-fpm")
    assert php.is_running
    assert php.is_enabled

def test_mysql_running_and_enabled(host):
    mysql = host.service("mysql")
    assert mysql.is_running
    assert mysql.is_enabled

def test_redis_running_and_enabled(host):
    redis = host.service("redis")
    assert redis.is_running
    assert redis.is_enabled

def test_nextcloudcron_running_and_enabled(host):
    nextcloudcron = host.service("nextcloudcron")
    assert nextcloudcron.is_running
    assert nextcloudcron.is_enabled
