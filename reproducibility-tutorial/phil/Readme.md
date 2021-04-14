# Reproducibility Tutorial step 2

## Computer setup

### Clone git repository

git clone https://github.com/kfreij95/Group-A-Capstone-I.git

### Download and install Miniconda

#download miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#install Miniconda
bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

#make sure all conda packages will be in path by symbolic links to /bin
ln -s /opt/conda/pkgs/*/bin/* /bin
ln -s /opt/conda/pkgs/*/lib/* /usr/lib

### Install Jupyter Lab 1.2.3

/opt/conda/bin/conda install -c conda-forge -y jupyterlab=1.2.3
/opt/conda/bin/conda install -c conda-forge -y nodejs=10.13.0
/opt/conda/bin/pip install bash_kernel
/opt/conda/bin/pip install ipykernel
/opt/conda/bin/python3 -m bash_kernel.install

#Test Jupyterlab
/opt/conda/bin/jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password='' --notebook-dir='/scratch/Group-A-Capstone-I/reproducibility-tutorial/'

### Install Snakemake
/opt/conda/bin/conda install -c bioconda -c conda-forge -y snakemake=5.8.1
#Handle path variables
ln -s /opt/conda/bin/* /bin
ln -s /opt/conda/lib/* /usr/lib

#verify the installation
snakemake --version

### Install Docker
#Update Ubuntu get package manager
sudo apt-get update

#install some needed packages
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#add the docker key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#add repo
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) \
 stable"
#update apt=get again
sudo apt-get update
#install docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
#test docker installation
docker run hello-world
