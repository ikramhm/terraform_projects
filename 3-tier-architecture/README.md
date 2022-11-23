This is a standard 3-tier monolithic architecture for AWS deployment. It utilises three EC2 instances: Front-end, Logic, (apache) and DB Instance, and an Application Load Balancer which serves traffic to the front-end Instances. As expected, the DB instance resides in a private subnet, and as such, the VPC set-up, internet and NAT gateway and subsequent route tables, alongside the appropriate security group rules have been set accordingly.

![image](https://user-images.githubusercontent.com/98710900/203631299-784dc3c7-a944-495f-b0ef-54ed16ae35ff.png)

Next steps: why dont I install the neccesary packages on the respective instances? It would be very easy to use a local-provisoner block to install this; though, implementation with Ansible maybe more prudent. 
