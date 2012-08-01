#! /bin/bash

: <<'INFO'

This script was created using ubuntu 12.04. 
It makes some changes in the system to make 
Creative SB X-FI 5.1 sound card work a little 
better :)
To be more particular:
	* preload ALSA modules at system boot
	* trigger actions when device is plugged:
		-reload pulseaudio
		-start daemons for remote control
	* remote control libraries
	* ability to switch active soundcards (remotely)

Author:		netikras <dariuxas@gmail.com>
Version:	0.2
Date:		2012.07.19
Location:	Lithuania

INFO
###############################################
###############################################

if [ `whoami` = root ]; then
    echo Please do not run this script as root or using sudo. Aborting...
    exit
fi

#+++++++++++++++++++++++

sudo apt-get install lirc lirc-x xdotool

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
# Set system username in configs#
#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
USERNAME=`whoami`
echo $USERNAME

for i in `ls files/`
do
	sed -i "s/my_username/${USERNAME}/g" files/$i
done


#+#+#+#+#+#+#+#
# Copy configs#
#+#+#+#+#+#+#+#
mkdir ~/skriptai
mkdir ~/skriptai/creative
mkdir ~/skriptai/creative/remote


# The following 3 lines are responsible for triggering particular events after soundcard is plugged
cp files/activate.sh ~/skriptai/creative/remote/activate.sh
sudo chmod +x ~/skriptai/creative/remote/activate.sh
sudo cp files/100-creative-SB-xFi-51.rules /etc/udev/rules.d/

cp files/audio ~/skriptai/creative/remote/audio
sudo chmod +x ~/skriptai/creative/remote/audio
cp files/volume-switch ~/skriptai/creative/remote/volume-switch
sudo chmod +x ~/skriptai/creative/remote/volume-switch

#+#+#+#+#+#+#+#+#+#+#+#+#+#
# Remote control libraries#
#+#+#+#+#+#+#+#+#+#+#+#+#+#
cp files/.lircrc ~/.lircrc
sudo cp files/lircd.conf.creative_RM-820 /usr/share/lirc/remotes/creative/lircd.conf.creative_RM-820
sudo cp files/lircd.conf /etc/lirc/lircd.conf
#sudo cp files/hardware.conf /etc/lirc/hardware.conf


###########################
#: <<'COMMENT'

sudo sed -i -e '/TRANSMITTER=/ s/=.*/="None"/' /etc/lirc/hardware.conf
sudo sed -i -e '/REMOTE_DRIVER=/ s/=.*/="alsa_usb"/' /etc/lirc/hardware.conf

# echo 'START_IREXEC="true"' | sudo tee -a /etc/lirc/hardware.conf
# sudo sh -c 'echo "START_IREXEC=\"true\"" >>/etc/lirc/hardware.conf'

if grep -q "START_IREXEC=" /etc/lirc/hardware.conf
	then
		#echo 'Found'
		sudo sed -i -e '/START_IREXEC=/ s/=.*/="true"/' /etc/lirc/hardware.conf
	else
		sudo sh -c 'echo "START_IREXEC=\"true\"" >>/etc/lirc/hardware.conf'
fi

#+#+#+#+#+#+#+#+#+#+#+#+#+#
# Preloading ALSA modules #
#+#+#+#+#+#+#+#+#+#+#+#+#+#
if grep -q "snd-usb-audio" /etc/default/grub
	then
		echo "GRUB will not be modified"
	else
		sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd-usb-audio /g' /etc/default/grub
		sudo update-grub
fi

#COMMENT
############################


#+#+#+#+#+#+#+#
# Restart LIRC#
#+#+#+#+#+#+#+#
sudo killall lircd
sudo lircd
sudo service lirc restart

echo
echo
echo
echo
echo
echo
echo DONE.
echo ++++++++++++++++++
echo Modify ~/.lircrc to map keys to events you need.
echo Process „irexec“ must be running in background in order to trigger events described in .lircrc
