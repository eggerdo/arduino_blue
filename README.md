<!-- Uses markdown syntax for neat display at github -->

# Programming of an Arduino over Bluetooth (on linux)

Many of you may have wondered already if it's not possible to program an arduino board over Bluetooth. We have wondered that too and done some research and trying out of different solutions found on the web. Getting ideas from all of them we came up with a solution that is easy and doesn't need much work to set up. All it takes will be descriped here. So far we have sucessfully programmed an Arduino Pro Mini together with a [Bluetooth Mate Silver](bluetooth mate sparkfun) from Sparkfun.

# Step 1: Bluetooth Mate Settings

First thing you need to do is change the baud rate of the Bluetooth Mate to 57600 as this is the speed it takes to upload your program. 

Connect to the Bluetooth Mate using a serial monitor program. (Picocom is a good choice as we will use that later on). Once connected, put the Bluetooth Mate into command mode by sending `$$$` (needs to be done withing 60 seconds of power on). The Mate will answer with `CMD`. Then change the baud rate to 57600 by sending `SU57`. The Mate will answer with `OK`. By typing `D` you can confirm the settings.

# Step 2: Arduino Reset circuit

In order to program the arduino, it has to be reset when the upload starts. To do this we first need to add a reset switch on the arduino board. Use a NPN transistor and connect it in the following way:

![Reset Switch on Breadboard](https://raw.github.com/eggerdo/arduino_blue/master/doc/reset_circuit.png)

1. Connect the collector to the reset pin on the arduino (example: blue wire connects to pin RST)
2. Connect the base to any output pin on the arduino (example: orange wire connects to pin 5)
3. Connect the emitter to the ground

With this ready we now need to put a piece of code in the arduino program that listens for a key on the bluetooth link and then then sets the chosen pin high to reset the board. In our case we use the char 'r' to reset the board:

	int ReadSerialInput()
	{
	  int incomingByte = 0;
	  
	  incomingByte = Serial.read();

	  switch (incomingByte) {
	    case 'r':
	      reset(1);
	      break;
	    }
	}

	void reset(int reset_delay) 
	{
	  delay(reset_delay * 1000);
	  digitalWrite(bootpin, HIGH);
	}

Call the function `ReadSerialInput();` from your loop and don't forget to set `Serial.begin(57600);` in your setup routine. 

# Step 3: Upload Program

The Arduino IDE seems to have serious problems with Bluetooth connections. Every time the Tools option menu is opened the IDE tries to open all the serial ports again wich fails because the IDE doesn't realise that the port is opened by itself.

To avoid this problem, we make use of the open source command line tool [ino](http://inotool.org/). The sourcecode is available from https://github.com/amperka/ino

# Scripts to make your life easy

Based an all these modifications I made scripts which will let you easily upload a new sketch. Checkout the code from the repository. It includes an example sketch together with the skripts `scan.sh`, `connect.sh`, `upload.sh` and `serial.sh`. If you want to use your own sketch, use ino to init a new folder, copy your sketch in the src folder and the scripts in the root folder and add the above code to your program.

## scan.sh

With `scan.sh` you can scan the bluetooth devices for Bluetooth Mates. If you're using a different Bluetooth device, change the variable DEVICE_FILTER used in the script or use `sudo hcitool -i hci0 scan` instead.

E.g.

	./scan.sh
	  00:06:66:45:B7:46    RN42-B746

## connect.sh

The script `connect.sh` is used to connect to the Bluetooth Mate. It expects the MAC address or the Device Name as a parameter. Once the connection is estables the scripts exits, if no connection can be established the script fails with an error message. 

## upload.sh

`upload.sh` is used to upload a new sketch to the arduino. It expects the MAC address or the Device Name as a parameter. (Alternatively you can write the address also in a file called arduino_ip.txt located in the same folder as the script)

E.g.

	./upload.sh -t RN42-B746

The script compiles the sketch located in the src folder, then connects to the arduino. Once connection is established it sends the reset signal to the arduino and starts uploading of the sketch.

If you include the option `-s` in the scripts call, the serial monitor is started and connects to the arduino once the upload is completed. 

E.g.

	./upload.sh -t RN42-B746 -s

## serial.sh

The same can also be achieved with `serial.sh`. It takes the same arguments as `upload.sh`, connects to the arduino and opens the serial monitor picocom to display the received data. 

E.g.

	./serial.sh -t RN42-B746
