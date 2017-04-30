module Infra
  module Commands
    module Servers; end
    module ServerTags; end
    module Keys; end
    module Domains; end
    module DomainTags; end
    module DomainRecords; end
  end
end

require 'infra/commands/base'
require 'infra/commands/servers/create'
require 'infra/commands/servers/delete'
require 'infra/commands/servers/update'
require 'infra/commands/server_tags/create'
require 'infra/commands/server_tags/delete'
require 'infra/commands/server_tags/update'
require 'infra/commands/keys/create'
require 'infra/commands/keys/delete'
require 'infra/commands/domains/create'
require 'infra/commands/domains/delete'
require 'infra/commands/domain_tags/create'
require 'infra/commands/domain_tags/delete'
require 'infra/commands/domain_records/create'
require 'infra/commands/domain_records/delete'
