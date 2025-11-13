Role Name
=========

Creates an AWS Transit Gateway Route Table Propagation.

Requirements
------------

The aws cli needs to be installed as the role uses the command module to call the aws cli.

Role Variables
--------------

# Required Variables
tgw_rtb_id: tgw-rtb-123456789
tgw_attach_id: tgw-attach-123456789

Dependencies
------------


Example Playbook
----------------

---
- name: "Create a Transit Gateway Route Table Propagation"
  hosts: localhost
  gather_facts: false
  collections:
    - custom_aws.ec2
  tasks:
    - name: Create Transit Gateway Route Table Propagation
      vars:
        tgw_rtb_id: "tgw-rtb-123456789"
        tgw_attach_id: "tgw-attach-123456789"
      import_role:
        name: custom_aws.ec2.transit_gateway_route_table_propagation
...

- name: "Create a Transit Gateway Route Table"
  hosts: localhost
  gather_facts: false
  roles:
    - { role: custom_aws.ec2.transit_gateway_route_table_propagation, tgw_rtb_id: tgw-rtb-123456789, tgw_attach_id: tgw-attach-12346789 }
...

License
-------

BSD

Author Information
------------------

Ryan Erickson
rerickso@redhat.com
