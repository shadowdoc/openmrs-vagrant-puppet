
#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 7.x
# It has been tested on CentOS 7.0 64bit

set -e

REPO_URL="http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm"

if [ "$EUID" -ne "0" ]; then
	echo "This script must be run as root." >&2
	exit 1
fi

if which puppet > /dev/null 2>&1; then
	echo "Puppet is already installed."
else
	# Install puppet labs repo
	echo "Configuring PuppetLabs repo..."
	repo_path=$(mktemp)
	wget --output-document="${repo_path}" "${REPO_URL}" 2>/dev/null
	rpm -i "${repo_path}" >/dev/null

	# Install Puppet...
	echo "Installing puppet"
	yum install -y puppet > /dev/null

	echo "Puppet installed!"
fi

if which git > /dev/null 2>&1; then
	echo "Git is already installed."
else
	echo "Installing git"
	yum install -y git > /dev/null
fi

# Additional installs from our repo to install gems and puppet modules

for f in /vagrant/gems/*
do
    echo "Installing gem: $f"
    gem install --local --ignore-dependencies --no-rdoc --no-ri $f
done


for f in /vagrant/puppet/modules/*
do
    echo "Installing $f...."
    puppet module install --ignore-dependencies $f
done

exit 0
