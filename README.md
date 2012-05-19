# Blimpy
[![Build Status](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/badge/icon)](https://buildhive.cloudbees.com/job/rtyler/job/blimpy/)

![Excelsior!](http://strongspace.com/rtyler/public/excelsior.png)


### About
Notes and other bits are being stored in [this public Evernote
notebook](https://www.evernote.com/pub/agentdero/blimpy).

The current concept/design document is captured in [this
note](https://www.evernote.com/pub/agentdero/blimpy#b=58a228bb-8910-4cd1-a7f5-995d775b81a2&n=06def701-7e25-425b-81d4-5811e7987c7e)


### The Blimpfile

Here's an example Blimpfile:

```ruby
    Blimpy.fleet do |fleet|
        fleet.add(:aws) do |ship|
            ship.image_id = 'ami-349b495d'
            ship.livery = 'rails'
            ship.group = 'Simple' # [Required] The name of the desired Security Group
            ship.region = 'us-west-1'
            ship.name = 'Rails App Server'
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
