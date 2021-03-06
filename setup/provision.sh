#!/bin/bash
#
# CS50 Vagrant provisioning script, run by Vagrantfile *inside the VM*
# when launched with
#    vagrant up --provision
#

success=true
log=/home/vagrant/provision.log

if ! touch $log; then
    echo Cannot write to $log.
    echo This script should only be run by vagrant, inside the virtual machine,
    echo and only when you run: vagrant up --provision
    exit 1
fi

# Try running a command, and if it fails, log about it.
function try() {
    echo "=====> $1" &>> $log;
    if ! $1 &>> $log;
    then echo "FAILED:  $1"; success=false; fi
}

echo Logging to $log...
echo Provision started &> $log

echo Protect your ssh keys... | tee -a $log
try "chmod 600 .ssh/id_rsa .ssh/id_rsa.pub"

echo Set to Eastern timezone... | tee -a $log
try "cp -f /usr/share/zoneinfo/US/Eastern /etc/localtime"

echo Installing necessary packages... | tee -a $log
packages='wget git gcc valgrind autoconf emacs manpages-posix-dev
          libncurses5-dev libncursesw5-dev'
try "apt-get update"
for package in $packages;
do
    try "apt-get install -y $package"
done

echo Installing dot files... | tee -a $log
dotdir=/home/vagrant/cs50-dev/dotfiles/virtualbox
for dot in $dotdir/*; do
    dotfile=.${dot##*/}
    dotlink=/home/vagrant/$dotfile
    rm -f $dotlink
    try "ln -s $dot $dotlink"
done

echo "Do all your work in ~/cs50-dev/" > /home/vagrant/DO-NO-WORK-HERE

if $success
then echo "Provision succeeded." | tee -a $log;
else echo "PROVISION FAILED; log in and review $log for details.";
fi
