#!/bin/bash
echo
echo "Appium processes (before):"
pidof node
echo "Adb processes (before):"
pidof adb
echo "ChromeDriver processes (before):"
pidof chromedriver
echo "Emulator processes (before):"
pidof qemu-system-x86_64
echo

echo "--Killing Emulator@port_5554--"
sudo kill -9 $(lsof -t -i:5554) > /dev/null 2>&1
echo "Pausing 10 seconds for node to purge any existing jobs..."
sleep 10
echo "--Killing Appium@port_4723--"
sudo kill -9 $(lsof -t -i:4723) > /dev/null 2>&1
echo "--Killing Adb--"
sudo adb kill-server
sudo pkill 'adb'
echo "--Killing chromeDriver@port_9515--"
sudo kill -9 $(lsof -t -i:9515) > /dev/null 2>&1

echo
echo "Appium processes (after):"
pidof node
echo "Adb processes (after):"
pidof adb
echo "ChromeDriver processes (after):"
pidof chromedriver
echo "Emulator processes (after):"
pidof qemu-system-x86_64
echo

echo "Backup, Compress and Clear Appium log file:"
sudo cp /tmp/appiumServer_4723.log /tmp/appiumServer_4723-$(date +%s).log
sudo zip -m /tmp/appiumServer_4723-logs.zip /tmp/appiumServer_4723-*.log
sudo rm /tmp/appiumServer_4723.log
echo

#Start adb and node, chromedriver will be automatically spawned
echo "Starting Adb"
sudo adb start-server
nohup /home/testing/android-sdk-linux/tools/emulator -port 5554 -avd Android_5_1_1 -no-window > /dev/null 2>&1 &
echo
echo "Waiting for emulator to launch..."
while ! nc -z localhost 5554; do
  sleep 0.5
done
echo "Emulator has launched."
echo
echo "Waiting for Emulator to boot..."
until sudo adb -s emulator-5554 shell getprop sys.boot_completed | grep -m 1 "1"; do
  sleep 1
done
echo "Emulator has finished booting."
echo
# Hard-coded coordinates for Android 5.1.1 and Nexus One screen size, orientation
echo "Dismissing emulator 'Welcome' screen."
sudo adb -s emulator-5554 shell input tap 393 356
nohup ~/bin/appium-server-on-4723.sh > /dev/null 2>&1 &
echo
echo "Waiting for Appium to launch..."
while ! nc -z localhost 4723; do
  sleep 0.5
done
echo "Appium has launched."
echo
echo "Querying Adb:"
sudo adb devices
#sleep 10
sudo netstat -nlpt
echo
cat /proc/meminfo | grep "MemAvailable:"
