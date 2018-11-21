require 'elasticsearch'
require 'elasticsearch-transport'
require 'logger'
require 'ansi/code'
require 'hashie/mash'

# The hosts to use for creating a elasticsearch client.
#
# @since 7.0.0
ELASTICSEARCH_HOSTS = ENV['ELASTICSEARCH_HOSTS'] ? ENV['ELASTICSEARCH_HOSTS'].split(',').freeze : [ '127.0.0.1:9250' ].freeze

# Are we testing on JRuby?
#
# @return [ true, false ] Whether JRuby is being used.
#
# @since 7.0.0
def jruby?
  RUBY_PLATFORM =~ /\bjava\b/
end

def node_names
  $node_names ||= default_client.nodes.stats['nodes'].collect do |name, stats|
    stats['name']
  end
end

def total_nodes
  ELASTICSEARCH_HOSTS.size
end

def default_client
  $client ||= Elasticsearch::Client.new(hosts: ELASTICSEARCH_HOSTS)
end

require 'patron' unless jruby?

module Config

  def self.included(context)

    # Get the hosts to use to connect an elasticsearch client.
    #
    # @since 7.0.0
    context.let(:hosts) { ELASTICSEARCH_HOSTS }
  end
end

RSpec.configure do |config|
  config.include(Config)
  config.formatter = 'documentation'
  config.color = true
end