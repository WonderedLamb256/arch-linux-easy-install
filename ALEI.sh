# Script: Install Arch Linux in One Script (for already partitioned PCs)
# Under GNU GPL license.
# By WonderedLamb256
# 3 stages: Format PC, Install Arch Linux, Install DE of choice

version=1.0.0 
echo 'Arch Linux Easy Install by WonderedLamb256 v$version'
sleep 1 
read -p 'Press enter to continue.'
options='Format InstallOS InstallDE Quit'
PS3='Choose install tool: '
select opt in $options
do
	if [ $options=='Quit' ]
	then
		echo 'Quitting...'
		break
	elif [ $options=='Format' ]
	then
		read rootdir 'Choose partition (e.g. sda1, sdb2, etc.): '
		options='ext4 BTRFS Fat32'
		PS3='Choose filesystem: '
		select opt in $options
		do
			if [ $options=='ext4' ]
			then
				mkfs.ext4 /dev/$rootdir
			elif [ $options=='BTRFS' ]
			then
				mkfs.btrfs /dev/$rootdir
			elif [ $options=='Fat32' ]
			then
				mkfs.fat -F32 /dev/$rootdir
			fi
		done
	elif [ $options=='InstallDE' ]
	then
		options='Gnome KDE XFCE'
		PS3='Choose DE: '
		select opt in $options
		do
		  arch-chroot /mnt && success=1 || success=0
			if [ success==0 ]
			then
				echo 'ERROR: devices unmounted'
				break
			elif [ success==1 ]
			then
				pacman -S xorg xorg-server
				if [ $options=='Gnome' ]
				then
					pacman -S gnome gnome-extra
					systemctl enable gdm.service
					systemctl start gdm.service
				elif [ $options=='KDE' ]
				then
					pacman -S plasma kde-applications gdm
					systemctl enable gdm.service
					systemctl start gdm.service
				elif [ $options=='XFCE' ]
				then
					pacman -S xfce4 xfce4-goodies gdm
					systemctl enable gdm.service
					systemctl start gdm.service
				fi
			fi
		done
	elif [ $options=='InstallOS' ]
	then
		read bootdir 'Choose boot (/boot) partition (e.g. sda1, sdb2, etc.): '
		pacstrap /mnt base
		mount /dev/$bootdir /mnt/boot
		genfstab -U /mnt >> /mnt/etc/fstab
		arch-chroot /mnt
		echo 'INFO: Default time zone is EST. Set time zone to other later.'
		ln -sf /usr/share/zoneinfo/EST
		hwclock --systohc
		echo 'INFO: Default locale is not chosen. Please choose locale later.'
		locale-gen
		mkinitcpio -p linux
		echo 'Enter root password... '
		passwd
		read username 'Enter your username... '
		useradd $username
		echo 'Enter user password... '
		passwd $username
		echo 'INFO: Normal user is not in the sudoers file. Edit the /etc/sudoers file later.'
		echo 'INFO: GRUB-bios is for BIOS only. The rest are for UEFI only.'
		options='GRUB-bios GRUB-uefi rEFInd EFISTUB'
		PS3='Choose bootloader: '
		select opt in $options
		do
			if [ $options=='GRUB-bios' ]
			then
				pacman -S grub
				grub-install --target=i386-pc /dev/$bootdir
				grub-mkconfig -o /mnt/boot/grub/grub.cfg
			elif [ $options=='GRUB-uefi' ]
			then
				pacman -S grub efibootmgr
				grub-install --target=x86_64-efi --efi-directory=/dev/$bootdir --bootloader-id=GRUB
				grub-mkconfig -o /mnt/boot/grub/grub.cfg
			elif [ $options=='rEFInd']
			then
				pacman -S refind-efi efibootmgr
				refind-install
			elif [ $options=='EFISTUB']
			then
				pacman -S efibootmgr
				read bootdirb 'Choose boot (/boot) partition number (e.g. 1, 2, etc.)'
				read rootdirb 'Choose full root drive (e.g. sda, sdb, etc.): '
				read rootuuid 'Choose root partition UUID (fdisk -l was ran before so you can check it)'
				efibootmgr --disk /dev/$rootdirb --part $bootdirb --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=$rootuuid rw initrd=\initramfs-linux.img' --verbose
			fi
		done
	fi
done
