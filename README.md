rubycas-server-core
===================
[![Circle CI](https://circleci.com/gh/vasilakisfil/rubycas-server-core.svg?style=svg)](https://circleci.com/gh/vasilakisfil/rubycas-server-core)

The core logic for handling CAS requests independent of any particular storage or web presentation technology.

## Requirements

* ruby 2.1.x

## Adapters
Currently available adapters are:
* [rubycas-server-activerecord](https://github.com/kollegorna/rubycas-server-activerecord)
* [rubycas-server-memory](https://github.com/vasilakisfil/rubycas-server-memory)

If you want to create a new adapter check these 2 adapters how they are implemented. Essentially you need to implement the following methods for each ticket:

```ruby

class XXXTicket
  def initialize(options = {})
  end
  
  #deprecated
  def self.find_by_ticket(ticket)
    #returns the ticket based on the ticket id
    #it will be removed soon
  end
  
  def self.find_by(opts = {})
    #returns the ticket based on the constraints in the hash (activerecord-style)
  end
  
  def save!
    #saves the ticket in the storage
    #throws an exception in case of an error
  end
  
  def save
    #saves the ticket in the storage
  end

  def consumed?
    #returns true if ticket is already consumed
  end

  def consume!
    #consumes the ticket
  end

  def expired?(max_lifetime = 100)
    #checks if the ticket is already expired
  end

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Coding conventions

1. String object as a hash key for all settings from Setting class.
