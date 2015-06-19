class base::interfaces {

  define base_l3_interface {
    $address = $name["address"]
    $netmask = $intf["netmask"]

    cumulus_interface { $name:
      ipv4   => "$address/$netmask",
      notify => Service['networking'],
    }
  }

  define base_bridge {
    $id      = $name["id"]
    $address = $name["address"]
    $netmask = $name["netmask"]
    $members = $name["members"]

    cumulus_bridge{ $name:
      ipv4   => "$address/$netmask",
      ports  => $members,
      notify => Service['networking'],
    }
  }

  if $int_enabled == undef {
      $int_enabled = false
  }

  if ($int_enabled == true) {
    cumulus_interface { 'lo':
      addr_method => 'loopback',
    }

    cumulus_interface { 'eth0':
      addr_method => 'dhcp',
    }

    # unnumbered interfaces
    if ($int_unnumbered != undef) {
      cumulus_interface { $int_unnumbered:
        ipv4   => "$int_loopback/32",
        notify => Service['networking'],
      }
    }

    # l3 interfaces
    if ($int_layer3 != undef) {
      base_l3_interface{ $int_layer3: }
    }

    # bridges
    if ($int_bridges != undef) {
      base_bridge{ $int_bridges: }
    }

    service { 'networking':
      ensure     => running,
      hasrestart => true,
      restart    => '/sbin/ifreload -a',
      enable     => true,
      hasstatus  => false,
      require    => Cumulus_license['workbench']
    }
  }
}
