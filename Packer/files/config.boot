system {
    /* host-name set via cloud-init. */
    /* users set via cloud-init. */
    syslog {
        global {
            facility all {
                level notice
            }
            facility protocols {
                level debug
            }
        }
    }
    ntp {
        server "0.pool.ntp.org"
        server "1.pool.ntp.org"
        server "2.pool.ntp.org"
    }
}

interfaces {
    ethernet eth0 {
        address dhcp
    }
    loopback lo {
    }
}

service {
    ssh {
        port 22
    }
}
