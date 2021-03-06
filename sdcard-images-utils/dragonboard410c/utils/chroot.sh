#!/bin/bash

qemu-aarch64-static /bin/bash

su - linaro

sudo apt-get update -yy -qq
sudo apt-get upgrade -yy -qq
sudo apt-get install v4l-utils -yy -qq
sudo apt-get install cmake -yy -qq
sudo apt-get install wget -yy -qq
sudo apt-get install xz-utils -qq
sudo apt-get install -yy -qq python3-pandas python3-natsort python3-matplotlib python3-tk python3-scipy python3-seaborn python3-serial
sudo apt-get install -yy -qq libssl-dev python-dev python3-dev build-essential libgtk2.0-dev pkg-config git

cd /home/linaro/workspace/github

wget --no-check-certificate --no-cache --no-cookies --header="If-Modified-Since: Sat, 1 Jan 2000 00:00:00 GMT" http://swdownloads.analog.com/cse/aditof/deps-dragonboard.tar.xz
tar -xf deps-dragonboard.tar.xz

sed -i 's+/home/linaro/workspace/github/tof_sdk/deps/installed/opencv-3.4.1+/usr/local+g' /home/linaro/workspace/github/deps/opencv-3.4.1/lib/pkgconfig/opencv.pc

cp -r /home/linaro/workspace/github/deps/opencv-3.4.1/* /usr/local/
cp -r /home/linaro/workspace/github/deps/glog/* /usr/local/
cp -r /home/linaro/workspace/github/deps/protobuf/* /usr/local/
cp -r /home/linaro/workspace/github/deps/websockets/* /usr/local/

cp -r /home/linaro/workspace/github/deps/py36tofcalib/lib/python3.5/site-packages/modbus_tk /usr/lib/python3/dist-packages/
cp -r /home/linaro/workspace/github/deps/py36tofcalib/lib/python3.5/site-packages/modbus_tk-1.0.0.dist-info /usr/lib/python3/dist-packages/

cp -r /home/linaro/workspace/github/deps/py36tofcalib/lib/python3.5/site-packages/click /usr/lib/python3/dist-packages/
cp -r /home/linaro/workspace/github/deps/py36tofcalib/lib/python3.5/site-packages/Click-7.0.dist-info /usr/lib/python3/dist-packages/

mkdir -p /home/linaro/.config/

cp -r /home/linaro/workspace/github/deps/chromium /home/linaro/.config/

sudo rm -rf /home/linaro/workspace/github/deps
sudo rm -rf /home/linaro/workspace/github/deps-dragonboard.tar.xz

sudo ldconfig

#git clone --branch d3/dev/Arrow https://omni.d3engineering.com/cgit/cgit.cgi/d3/adi/tof_sdk.git/
git clone --branch $1 https://omni.d3engineering.com/cgit/cgit.cgi/d3/adi/tof_sdk.git/

cd tof_sdk

mkdir -p build
cd build
cmake .. -DDRAGONBOARD=1 -DWITH_PYTHON=on
make -j8

# This will error when executing. The udev rules are actually
# copied in /etc/udev/rules.d. The error is coming from running:
# udevadm control --reload-rules
# udevadm trigger 
# This is not an issue as we don't need to reload the rules in this context
sudo make install-udev-rules

cd /home/linaro/workspace/github/tof_sdk/apps/daemon
sudo cp tof-programming.service /etc/systemd/system/
mkdir -p build
cd build
cmake ..
make -j8
sudo systemctl enable tof-programming

cd /home/linaro/workspace/github/tof_sdk/utils/dragonboard
sudo cp config_pipe.service /etc/systemd/system/
sudo systemctl enable config_pipe

mkdir -p /home/linaro/Desktop
cd /home/linaro/Desktop
touch aditof-demo.sh
echo '#!/bin/bash' >> aditof-demo.sh
echo 'cd /home/linaro/workspace/github/tof_sdk/build/examples/aditof-demo' >> aditof-demo.sh
echo './aditof-demo' >> aditof-demo.sh
sudo chmod +x aditof-demo.sh

sudo cp /home/linaro/info.txt /home/linaro/Desktop
sudo rm /home/linaro/info.txt

# fix
sudo chown -R linaro:linaro /home/linaro/workspace
sudo chown -R linaro:linaro /home/linaro/.config
sudo chown -R linaro:linaro /home/linaro/Desktop
