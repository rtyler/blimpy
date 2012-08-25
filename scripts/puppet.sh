#!/bin/sh -x

OSNAME=`uname`

if [ "${OSNAME}" = "FreeBSD" ]; then

  which pkg > /dev/null

  if [ $? -ne 0 ]; then
    echo "pkgng is not installed!"
    ftp -V ftp://anonymous:ec2@ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/pkg.tbz
    pkg_add ./pkg.tbz

    echo "PACKAGESITE : http://pkgbeta.freebsd.org/freebsd-9-amd64/latest/" > /usr/local/etc/pkg.conf

    pkg update -q
    # Update pkgng itself
    pkg install -y pkg
    # Install rsync(1) so we don't have to fall back to tar(1)+scp(1) ever again
    pkg install -y rsync
    # Install puppet so we can get that up and running
    pkg install -y puppet
  fi;

else

  export PATH=/var/lib/gems/1.8/bin:$PATH

  which puppet

  if [ $? -ne 0 ]; then
      apt-get update

      apt-get install -y ruby1.8 \
                      ruby1.8-dev \
                      libopenssl-ruby1.8 \
                      rubygems

      gem install puppet --no-ri --no-rdoc
  fi

fi
