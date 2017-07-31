# frozen_string_literal: true
include_recipe 'onms_lwrp_test::event'
opennms_event 'edit operinstruct' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  file 'events/chef.events.xml'
  operinstruct 'the operinstructed'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
