# dracut-netplan

Enable netplan support for early boot networking

## Usage

Install this package, make sure you have your configuration in /etc/netplan,
and rebuild your initrd with dracut. The netplan configuration will be used on
early boot.
