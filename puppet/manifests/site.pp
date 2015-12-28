include epel

class { 'selinux':
 mode => 'enforcing'
}

class { 'java':
  distribution => 'jre',
  version => '1.7.0.75-2.5.4.2.el7_0'
}

class { '::mysql::server':
 root_password    => hiera('mysql_root'),
 override_options => $override_options
}

package {
    'unzip':
        ensure      => installed,
        provider    => yum
}

exec {
    "unzip_openmrs_sql":
    cwd => "/vagrant/SQL",
    path => "/usr/bin",
    creates => "/vagrant/SQL/openmrs.sql",
    command => "/usr/bin/unzip /vagrant/SQL/openmrs.zip",
    require => Package["unzip"]
}

class { 'tomcat':
  install_from_source => false,
  purge_connectors => true,
}


# create openmrs database with a new openmrs user
# fill it with the source data and install Tomcat
mysql::db { 'openmrs':
  user     => 'openmrs_user',
  password => hiera('mysql_openmrs_user'),
  host     => 'localhost',
  grant    => ['ALL'],
  sql      => '/vagrant/SQL/openmrs.sql',
}->
tomcat::instance{ 'default':
  package_name => 'tomcat',
  require =>  [
                Mysql::Db["openmrs"],
                File['/var/lib/OpenMRS/openmrs-runtime.properties'],
                File['/var/lib/OpenMRS/tomcat-keystore']
              ]
}->
tomcat::service { 'default':
  service_ensure => 'running',
  use_jsvc     => false,
  use_init     => true,
  service_name => 'tomcat',
}->
tomcat::config::server { 'default':
  catalina_base => '/usr/share/tomcat',
  port          => '8005',
}->
tomcat::config::server::connector { 'tomcat-https':
  catalina_base         => '/usr/share/tomcat',
  port                  => '8443',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'SSLEnabled' => 'true',
    'clientAuth' => 'false',
    'keystoreFile' => '/var/lib/OpenMRS/tomcat-keystore',
    'keystorePass' => 'changeit',
    'ciphers' => 'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA'
  },
}->
tomcat::war { 'openmrs.war':
  catalina_base => '/usr/share/tomcat/',
  war_source => '/vagrant/openmrs-platform-1.10.1.war',
}->

# Chain of firewall commands for tomcat

firewalld::service { 'tomcat':
  description   => 'Tomcat application server',
  short         => 'tomcat',
  ports         => [{port => '8080', protocol => 'tcp',},{port => '8443', protocol => 'tcp',}],
  require       => Tomcat::Service["default"]
}->
exec {
  "restart_firewalld_after_tomcat_service":
    path => "/usr/bin",
    command => "systemctl restart firewalld",
}->
exec {
  "add_tomcat_to_public_zone":
    path => "/usr/bin",
    command => "firewall-cmd --permanent --zone=public --add-service=tomcat",
    notify => Service["firewalld"];
}

#creates the openmrs directory for properties and install the necessary modules
file { ["/var/lib/OpenMRS"]:
    ensure => "directory",
    mode   => 750,
    owner => tomcat,
    group => root,
    #source => "/vagrant/openmrs-runtime.properties",
}->
file { ["/var/lib/OpenMRS/modules"]:
    ensure => "directory",
    mode   => 750,
    owner => tomcat,
    group => root,
    source => "/vagrant/omods/",
    recurse => true
}->
file { '/var/lib/OpenMRS/openmrs-runtime.properties':
          ensure => present,
          source => "/vagrant/openmrs-runtime.properties",
          mode   => 750,
          owner => tomcat,
          group => root,
}->
file {'/var/lib/OpenMRS/tomcat-keystore':
    ensure => present,
    source => '/vagrant/tomcat-keystore',
    mode => 600,
    owner => tomcat,
    group => root,
}

