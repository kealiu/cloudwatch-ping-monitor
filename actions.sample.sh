#!/bin/bash


# we can update table delete route and add new ones
aws ec2 delete-route --route-table-id rtb-11111111 --destination-cidr-block 10.0.0.0/16
aws ec2 create-route --route-table-id rtb-11111111 --destination-cidr-block 10.0.0.0/16 --vpc-peering-connection-id pcx-22222222

