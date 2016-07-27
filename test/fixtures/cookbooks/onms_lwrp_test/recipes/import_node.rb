# mixin our library
class Chef::Recipe
  include Provision
end
# note that opennms needs to be running for provisioning commands to work
# as they use the ReST interface.
log 'Start OpenNMS to perform ReST operations.' do
  notifies :start, 'service[opennms]', :immediately
end
# minimal
opennms_import_node 'nodeA' do
  foreign_source_name 'dry-source'
  foreign_id 'nodeA_ID'
end

# make us a new foreign_id using the Provision library
# (creates a new node with the same name every time it converges)
node_b_foreign_id = foreign_id_gen
# common options
opennms_import_node 'nodeB' do
  foreign_source_name 'dry-source'
  foreign_id node_b_foreign_id
  building 'HQ'
  categories %w(Servers Test)
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838931'
end

node_c_foreign_id = 'nodeC'
# all options
opennms_import_node 'nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_foreign_source 'dry-source'
  parent_foreign_id node_b_foreign_id
  parent_node_label 'nodeB'
  city 'Tulsa'
  building 'Barn'
  categories %w(Servers Test)
  assets 'vendorPhone' => '511', 'serialNumber' => 'SN12838932'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
end

opennms_import_node 'rename nodeC' do
  node_label 'node-c.example.net'
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  sync_import true
end

opennms_import_node 'change parent nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_node_label 'nodeA'
  parent_foreign_id 'nodeA_ID'
  sync_import true
end

opennms_import_node 'change city nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  city 'Brooklyn'
  sync_import true
end

opennms_import_node 'change building nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  building 'Big'
  sync_import true
end

opennms_import_node 'change categories nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  categories %w(Servers Dev)
  sync_import true
end

opennms_import_node 'change assets nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  assets 'vendorPhone' => '311'
  sync_import true
end

# should do nothing
opennms_import_node 'nothing nodeC' do
  node_label 'node-c.example.net'
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_node_label 'nodeA'
  parent_foreign_id 'nodeA_ID'
  city 'Brooklyn'
  building 'Big'
  categories %w(Servers Dev)
  assets 'vendorPhone' => '311'
  sync_import true
end

opennms_import_node 'nothing for different reasons nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  sync_import true
  action :create_if_missing
end

opennms_import_node 'delete nodeB' do
  foreign_source_name 'dry-source'
  foreign_id node_b_foreign_id
  action :delete
end
