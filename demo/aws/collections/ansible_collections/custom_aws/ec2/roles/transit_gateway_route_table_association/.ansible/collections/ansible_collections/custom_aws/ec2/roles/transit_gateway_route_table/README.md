Role Name
=========

Creates an AWS Transit Gateway Route Table or sets/prints its ID if one route table with that name already exists.

Requirements
------------

The aws cli needs to be installed as the role uses the command module to call the aws cli.

Role Variables
--------------

# Required Variables
tgw_rt_name: tgw-rt-example
tgw_id: tgw-abcdefghijklmnopqrstuvwxyz

Dependencies
------------


Example Playbook
----------------

---
- name: "Create a Transit Gateway Route Table"
  hosts: localhost
  gather_facts: false
  collections:
    - custom_aws.ec2
  tasks:
    - name: Create Transit Gateway Route Table
      vars:
        tgw_rt_name: "tgw-rt-example"
        tgw_id: "tgw-abcdefghijklmnopqrstuvwxyz"
      import_role:
        name: custom_aws.ec2.transit_gateway_route_table

    - name: Debug Role Outputs
      ansible.builtin.debug:
        var: custom_aws_ec2_transit_gateway_route_table
...

- name: "Create a Transit Gateway Route Table"
  hosts: localhost
  gather_facts: false
  roles:
    - { role: custom_aws.ec2.transit_gateway_route_table, tgw_rt_name: tgw-rt-example, tgw_id: tgw-abcdefghijklmnopqrstuvwxyz }
  tasks:
    - name: "Debug Role Outputs"
      ansible.builtin.debug:
        var: custom_aws_ec2_transit_gateway_route_table

...

# Example Output:
#ok: [localhost] => {
#    "custom_aws_ec2_transit_gateway_route_table": {
#        "tgw-rt-example": {
#            "tgw_id": "tgw-abcdefghijklmnopqrstuvwxyz",
#            "tgw_rt_id": "tgw-rtb-abcdefghijklmnopqrstuvwxyz",
#        }
#    }
#}

License
-------

BSD

Author Information
------------------

Ryan Erickson
rerickso@redhat.com
