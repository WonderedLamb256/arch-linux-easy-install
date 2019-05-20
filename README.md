# arch-linux-easy-install

**Easy installer for Arch Linux, but it’s genuine Arch!**
ALEI is a semi-interactive Arch Linux easy installer made for people who have learned enough to get out of Manjaro and Antergos, but not enough to hand-install Arch. Enjoy! -WonderedLamb256

# Install

Clone this git repo using `git clone` or by clicking the 'clone repo' button at the repository website. Next, you'll want to put this on a USB drive by using `mv` to move the .sh file from the repo folder to the drive. Then, in the archiso live USB, format (use ext4/btrfs for home/root and fat32 for boot), and mount your root partition. Finally, mount the USB drive with the .sh on it, cd into /mnt/*USB*, run `./ALEI.sh`, select the `installos` option, once it's finished run `exit && reboot`, mount and cd into it again, and finally select the `installde` option. You now have a fully complete Arch Linux install!
