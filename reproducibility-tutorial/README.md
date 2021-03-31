#Clone repository
git clone https://github.com/kfreij95/Group-A-Capstone-I.git

#download the Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#install miniconda silently (-b) in path (-p) /opt/conda
bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

#make sure all conda packages will be in path by symbolic links to /bin
ln -s /opt/conda/pkgs/*/bin/* /bin
ln -s /opt/conda/pkgs/*/lib/* /usr/lib

#Install Jupyter lab version 1.2.3
/opt/conda/bin/conda install -c conda-forge -y jupyterlab=1.2.3
/opt/conda/bin/conda install -c conda-forge -y nodejs=10.13.0
/opt/conda/bin/pip install bash_kernel
/opt/conda/bin/pip install ipykernel
/opt/conda/bin/python3 -m bash_kernel.install


#Test Jupyterlab
jupyter lab --no-browser --allow-root --ip=128.196.142.80:8888 \ 
--NotebookApp.token='' --NotebookApp.password='' \ 
--notebook-dir='/scratch/reproducibility-tutorial/'

#Install Snakemake
/opt/conda/bin/conda search -c bioconda snakemake
/opt/conda/bin/conda install -c bioconda -c conda-forge -y snakemake=5.8.1
ln -s /opt/conda/bin/* /bin
ln -s /opt/conda/lib/* /usr/lib
snakemake --version

#Install Docker
sudo apt-get update
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common

#Add Docker key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Add repository
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) \
 stable"

#Update apt-get with new repository information
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#Test Docker
docker run hello-world

#History storage
cd /scratch
mkdir reproducibility-tutorial/
cd reproducibility-tutorial/
history >>README.md
