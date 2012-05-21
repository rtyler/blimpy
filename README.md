# Blimpy
[![Build Status](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/badge/icon)](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/)

![Excelsior!](http://strongspace.com/rtyler/public/excelsior.png)


### About

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

(Inspired by [Vagrant](http://vagrantup.com))

Notes and other bits are being stored in [this public Evernote
notebook](https://www.evernote.com/pub/agentdero/blimpy).

The current concept/design document is captured in [this
note](https://www.evernote.com/pub/agentdero/blimpy#b=58a228bb-8910-4cd1-a7f5-995d775b81a2&n=06def701-7e25-425b-81d4-5811e7987c7e)


### The Blimpfile

Here's an example Blimpfile:

```ruby
    Blimpy.fleet do |fleet|
        fleet.add(:aws) do |ship|
            ship.name = 'rails-app'
            ship.ports = [22, 80, 8080] # [Optional] Create a security group with these ports open
            ship.image_id = 'ami-349b495d' # [Optional] defaults to Ubuntu 10.04 64-bit
            ship.livery = 'rails' # [Optional]
            ship.group = 'Simple' # [Optional] The name of the desired Security Group
            ship.region = 'us-west-1' # [Optional] defaults to us-west-2
            ship.username = 'ubuntu' # [Optional] SSH username, defaults to "ubuntu" for AWS machines
        end
    end
```


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
