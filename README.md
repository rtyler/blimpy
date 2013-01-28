# Blimpy
[![Build Status](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/badge/icon)](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/)

![Excelsior!](http://strongspace.com/rtyler/public/excelsior.png)


## About

Blimpy is a tool to help developers spin up and utilize machines "in the
cloud."

Once a developer has a Blimpfile, they can execute a few simple commands to
manage the newly created "fleet" in the specified cloud provider:

```
   % blimpy start
   [snip]
   >> excelsior ..... online at: ec2-50-112-3-57.us-west-2.compute.amazonaws.com..
   >> goodyear ..... online at: ec2-50-112-27-89.us-west-2.compute.amazonaws.com
   %
```

Once machines are online, they're easy to access by name with:

```
  % blimpy scp goodyear secrets.tar.gz
  % blimpy ssh goodyear
```

Then once you're finished working with the machines a simple `blimpy destroy`
will terminate the machines.


---

## The Blimpfile

Here's an example Blimpfile:

```ruby
    Blimpy.fleet do |fleet|
        fleet.add(:aws) do |ship|
            ship.name = 'rails-app'
            ship.ports = [22, 80, 8080] # [Optional] Create a security group with these ports open
            ship.image_id = 'ami-4438b474' # [Optional] defaults to Ubuntu 12.04 64-bit
            ship.livery = Blimpy::Livery::CWD # [Optional]
            ship.group = 'Simple' # [Optional] The name of the desired Security Group
            ship.region = 'us-west-1' # [Optional] defaults to us-west-2
            ship.username = 'ubuntu' # [Optional] SSH username, defaults to "ubuntu" for AWS machines
            ship.flavor = 'm1.small' # [Optional] defaults to t1.micro
            ship.tags = {:mytag => 'somevalue'}
        end
    end
```

### Supported Clouds

Currently Blimpy supports creating machines on:

 * [Amazon Web Services](https://github.com/rtyler/blimpy/wiki/AWS) - using the `:aws` argument passed into `fleet.add`
 * [OpenStack](https://github.com/rtyler/blimpy/wiki/OpenStack) - using the `:openstack` argument passed into `fleet.add`

---

### What is Livery?

In aviation, livery is the insignia or "look" an aircraft typically has. For
example, Alaskan Airlines has a distinctive "[creepy mountain
man](http://farm1.static.flickr.com/135/333644732_4f797d3c22.jpg)" livery on
every plane.

With Blimpy, "livery" is a similar concept, a means of describing the "look" of
a specific machine in the cloud. Currently the concept is still on the drawing
board, but if you would imagine a tarball containing a `bootstrap.sh` script
and Chef cookbooks or Puppet manifests to provision the entirety of the machine
from start-to-finish.

When the machine comes online, the specified livery would be downloaded from S3
(for example) and bootstrap.sh would be invoked as root.
