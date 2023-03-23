# port_scan

Simple single-threaded port scanner using `TCPSocket`

## Installation

```sh
git clone https://github.com/js-on.de/WeaponizeCrystal.git
cd WeaponizeCrystal/port_scan
shards install
# compile
crystal build --single-module src/port_scan.cr
```

## Usage
`Usage:   ./port_scan IP PORT_RANGE`

*Simple portscan with IP and single port range*
```
./port_scan 127.0.0.1 500-5000
Portscan for 127.0.0.1 has taken 140ms
TCP Port 500 to 5000 have been scanned
Found 4497 closed ports
Found 3 open ports
  - 631
  - 4767
  - 4769
```

## Development

See [Contributing](https://github.com/js-on/WeaponizeCrystal/tree/main/port_scan#Contributing)

## Contributing

1. Fork it (<https://github.com/js-on/WeaponizeCrystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [js-on](https://github.com/js-on) - creator and maintainer