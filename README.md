# Mu (µ)

Welcome to the Ruby edition of ___Microservices Unbound___!

This gem serves as the base component for building Ruby microservices. It will eventually provide a full
complement of straightforward and easy to use APIs that will serve as a "running start" for building a distributed
service-oriented architecture of small services.

## Features

From experience, I have discovered that there is a small but essential set of behaviors that microservices must
implement for this architecture to succeed. The fundamental reason for this is that increasing the number of moving
parts in a system does, by its very definition, increase complexity. This complexity is manageable, but only if steps
are taken to insure that all services can be viewed, scaled, monitored and maintained in a similar fashion.

### Logging

Provide a simple, easy-to-understand API that will:

  * Capture key-value sets for all log events rather than simple strings
  * Uniformly include discriminating attributes in all events (service name, host, instance)
  * Provide easy to read formatting for local use by developers
  * Provide formatting as JSON for subsequent filtering, processing, and/or indexing by a log aggregator
  * Cross-service session identification

### Configuration

  * Make it easy to specify configuration across a multiple dimensions: service, environment, local overrides.
  * Log all configuration data when a service starts up

### Inter-Service Communication

  * Simple data marshalling
  * Synchronous Communication via REST utilizing JSON API
    * REST-ful endpoint implementation skeletons
    * Middleware to handle logging and security
    * REST client abstraction for JSON API compliant services (e.g. other Mu-enabled services)
    * Generic HTTP client abstraction for external and other non-standard REST APIs
  * Asynchronous Communication via AMQP
    * Broadcast (event bus)
    * Service-to-Service (psuedo-synchronous messaging)
    * Backchannel (control bus)

### Authentication / Authorization

  * Authenticate all incoming requests
  * Provide role-based authorization requirements by endpoint
  * Pass credentials of incoming requests on with subsequent requests

### Storage

  * RDBMS
  * Key-Value Stores (e.g. Riak, Redis)
  * File/Bulk Storage (e.g. S3)

## Additional Components

The converse of these simple APIs for services is to provide components that enable these capabilities across a
 distributed system. For example, a good logging API needs a centralized log aggregator. Here are some of the
 infrastructure components that I have in mind to provide as starting points:

  * Log Aggregator: Elasticsearch/Logstash/Kibana (ELK stack)
  * Basic admin/monitoring service
    * Serves as an example implementation service using the mu-ruby gem.
    * Monitors service availability using the AMQP backchannel
    * Provides visibility of the configuration in use for any given service
  * Sample deployment template for AWS using Terraform and Ansible
  * Sample single-machine development environment using Docker
  * Sample cross-service integration tests using Cucumber




## Installation

**None of this is valid yet, this gem has not been pushed to Rubygems.**

Add this line to your application's Gemfile:

```ruby
gem 'mu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mu

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goneflyin/mu-ruby.
