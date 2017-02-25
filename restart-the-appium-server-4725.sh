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

echo "--Killing Emulator@port_5556--"
sudo kill -9 $(lsof -t -i:5556) > /dev/null 2>&1
echo "Pausing 10 seconds for node to purge any existing jobs..."
sleep 10
echo "--Killing Appium@port_4725--"
sudo kill -9 $(lsof -t -i:4725) > /dev/null 2>&1
echo "--Killing Adb--"
sudo adb kill-server
sudo pkill 'adb'
echo "--Killing chromeDriver@port_9517--"
sudo kill -9 $(lsof -t -i:9517) > /dev/null 2>&1

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
sudo cp /tmp/appiumServer_4725.log /tmp/appiumServer_4725-$(date +%s).log
sudo zip -m /tmp/appiumServer_4725-logs.zip /tmp/appiumServer_4725-*.log
sudo rm /tmp/appiumServer_4725.log
echo

#Start adb and node, chromedriver will be automatically spawned
echo "Starting Adb:"
sudo adb start-server
nohup /home/testing/android-sdk-linux/tools/emulator -port 5556 -avd Android_7 -no-window > /dev/null 2>&1 &
echo
echo "Waiting for emulator to launch..."
while ! nc -z localhost 5556; do
  sleep 0.5
done
echo "Emulator has launched."
echo
echo "Waiting for Emulator to boot..."
until sudo adb -s emulator-5556 shell getprop sys.boot_completed | grep -m 1 "1"; do
  sleep 1
done
echo "Emulator has finished booting."
echo
# Hard-coded coordinates for Android 7 and WSVGA screen size, orientation
echo "Dismissing emulator 'Welcome' screen."
sudo adb -s emulator-5556 shell input tap 626 328
nohup ~/bin/appium-server-on-4725_emulator.sh > /dev/null 2>&1 &
echo
echo "Waiting for Appium to launch..."
while ! nc -z localhost 4725; do
  sleep 0.5
done
echo "Appium has launched."
echo
echo "Querying Adb:"
sudo adb devices
sudo netstat -nlpt
echo
cat /proc/meminfo | grep "MemAvailable:"
