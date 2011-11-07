#
# Author:: James Turnbull <james@puppetlabs.com>
# Module Name:: bprobe
#
# Copyright 2011, Puppet Labs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class bprobe {

  require bprobe::params
  require bprobe::dependencies

  $username       = $bprobe::params::username
  $apikey         = $bprobe::params::apikey
  $collector      = $bprobe::params::collector
  $collector_port = $bprobe::params::collector_port

  boundary_meter { $fqdn:
    ensure   => present,
    username => $username,
    apikey   => $apikey,
  }

  file { '/etc/bprobe/':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  package { 'bprobe':
    ensure  => latest,
    require => File['/etc/bprobe'],
  }

  file { '/etc/bprobe/bprobe.defaults':
    ensure  => present,
    content => template('bprobe/bprobe.defaults.erb'),
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    notify  => Service['bprobe'],
    require => Package['bprobe'],
  }

  file { '/etc/bprobe/ca.pem':
    ensure  => present,
    source  => 'puppet:///modules/bprobe/ca.pem',
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    notify  => Service['bprobe'],
    require => Package['bprobe'],
  }

  service { 'bprobe':
    ensure  => running,
    enable  => true,
    require => Package['bprobe'],
  }
}