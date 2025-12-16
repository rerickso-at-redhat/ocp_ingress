Role Name
=========

Creates an AWS Transit Gateway Route Table or sets/prints its ID if one route table with that name already exists.

Requirements
------------

boto3

Role Variables
--------------

# Required Variables
tgw_rt_name: example-tgw-route-table-name

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: localhost
      roles:
         - { role: custom_aws.ec2.transit_gateway_route_table, tgw_rt_name: example-tgw-route-table-name }

License
-------

BSD

Author Information
------------------

Ryan Erickson
rerickso@redhat.com
