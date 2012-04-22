# Blimpy


Notes and other bits are being stored in [this public Evernote
notebook](https://www.evernote.com/pub/agentdero/blimpy).

The current concept/design document is captured in [this
note](https://www.evernote.com/pub/agentdero/blimpy#b=58a228bb-8910-4cd1-a7f5-995d775b81a2&n=06def701-7e25-425b-81d4-5811e7987c7e)


### Blimpfile

Here's an example Blimpfile:

```ruby
    Blimpy.fleet do |fleet|
        fleet.add do |host|
            host.image_id = 'ami-349b495d'
            host.livery = 'rails'
            host.group = 'Simple'
            host.region = :uswest
            host.name = 'Rails App Server'
        end
    end
```
