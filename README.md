<!-- Uses markdown syntax for neat display at github -->

# Programming of an Arduino over Bluetooth (on linux)

Many of you may have wondered already if it's not possible to program an arduino board over Bluetooth. We have wondered that too and done some research and trying out of different solutions found on the web. Getting ideas from all of them we came up with a solution that is easy and doesn't need much work to set up. All it takes will be descriped here. So far we have sucessfully programmed an Arduino Pro Mini together with a [Bluetooth Mate Silver](bluetooth mate sparkfun) from Sparkfun.

## Step 1: Change the Bluetooth Configuration

First thing you need to do is change the baudrate of the Bluetooth Mate to 57600 as this is the speed with which the atmega is being programmed. To to this you need to pair first with the Bluetooth Mate.

1. scan for bluetooth devices and note down the mac address of the Bluetooth Mate. The name is of the form RN42-...
sudo hcitool -i hci0 scan
Scanning ...
    00:06:66:45:B7:46    RN42-B746

2. pair with the Bluetooth Mate
bluez-simple-agent hci0 00:06:66:45:B7:46
RequestPinCode (/org/bluez/1129/hci0/dev_00_06_66_45_B7_46)
Enter PIN Code: 1234
Release
New device (/org/bluez/1129/hci0/dev_00_06_66_45_B7_46)

3. 


Then use a terminal program to connect to 
