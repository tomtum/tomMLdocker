FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

MAINTAINER tomtum

# Setup timezone
ENV TZ=Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install some dependencies
RUN apt-get update && apt-get install -y \
bc \
build-essential \
git \
curl \
g++ \
gfortran \
libgtk2.0-dev \
libtbb2 \
libtiff-dev \
libffi-dev \
libfreetype6-dev \
libhdf5-dev \
libjpeg-dev \
liblcms2-dev \
libopenblas-dev \
liblapack-dev \
libssl-dev \
libtiff5-dev \
libwebp-dev \
libzmq3-dev \
nano \
pkg-config \
python-dev \
python-numpy \
python3-dev \
python3-pip \
software-properties-common \
unzip \
vim \
wget \
zlib1g-dev \
qt5-default \
libvtk6-dev \
zlib1g-dev \
libjpeg-dev \
libwebp-dev \
libpng-dev \
libtiff5-dev \
libopenexr-dev \
libgdal-dev \
libdc1394-22-dev \
libavcodec-dev \
libavformat-dev \
libswscale-dev \
libtheora-dev \
libvorbis-dev \
libxvidcore-dev \
libx264-dev \
yasm \
libopencore-amrnb-dev \
libopencore-amrwb-dev \
libv4l-dev \
libxine2-dev \
libtbb-dev \
libeigen3-dev \
python-pip \
python3-tk \
python3-numpy \
python3-venv \
sudo \
ant \
default-jdk \
doxygen && \
apt-get clean && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/*
# rm -rf /var/lib/apt/lists/* && \
# update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3

# Install latest CMake
RUN apt-get update && apt-get install apt-transport-https ca-certificates gnupg software-properties-common -y && \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
apt-get update && apt-get install cmake -y

# Install jpeg2000
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
apt update && \
apt install libjasper1 libjasper-dev

# Install Python packages
RUN apt-get update && apt-get install -y \
python3-scipy \
python3-nose \
python3-h5py \
python3-skimage \
python3-matplotlib \
python3-pandas \
python3-sklearn \
python3-sympy \
&& \
apt-get clean && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

# Install other useful Python packages using pip
RUN pip3 --no-cache-dir install --upgrade ipython && \
pip3 --no-cache-dir install \
Cython \
ipykernel \
jupyter \
path.py \
Pillow \
pygments \
six \
sphinx \
wheel \
zmq \
&& \
python3 -m ipykernel.kernelspec

# Istall TensorFlow and Keras
RUN pip3 install tensorflow

# Make directories for libraries
RUN mkdir /root/torch
RUN mkdir /root/opencv4.3

# Install Torch
RUN git clone https://github.com/nagadomi/distro.git /root/torch --recursive && \
cd /root/torch && \
sed -i 's/python-software-properties/software-properties-common/g' install-deps && \
bash install-deps && \
./install.sh && \
./update.sh && \
/bin/bash -c "source ~/.bashrc" && \
./clean.sh

# Install PyTorch
RUN pip3 install torch torchvision

# Install OpenCV
RUN cd /root/opencv4.3 && \
git clone https://github.com/opencv/opencv.git --branch 4.3.0 && \
git clone https://github.com/opencv/opencv_contrib --branch 4.3.0 && \
cd ./opencv && \
mkdir build && \
cd build && \
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/  -DOPENCV_GENERATE_PKGCONFIG=ON .. && \
make -j"$(nproc)"  && \
make install && \
ldconfig && \
echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

# Install OpenCV for Python
RUN pip3 install opencv-contrib-python

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE 6006 8888

RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64
RUN sudo ln -s /usr/local/cuda-10.2/targets/x86_64-linux/lib/libcudart.so.10.2 /usr/lib/x86_64-linux-gnu/libcudart.so.10.1 && \
/bin/bash -c "source ~/.bashrc"

WORKDIR "/root"
CMD ["/bin/bash"]