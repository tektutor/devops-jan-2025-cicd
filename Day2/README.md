# Day 2 

## Configuration Management Tool Overview
<pre>
- is used to automate system administration activities
- the assumption is we already have a machine with some OS ( Unix, Linux, Windows or Mac )
- this tool is used to install/configure stuffs on an already provisioned machine
- examples
  - Chef
  - Puppet
  - Ansible
</pre>

## Puppet Overview
<pre>
- is the oldest configuration management tool
- it follows client/server architecture
- every configuration management supports a specific domain specific language (DSL) to automate stuffs 
- the DSL used by Puppet is Puppet language ( a proprietary declarative language )
- Puppet installation is very complex and time consuming
- learning curve is quite steep
- uses proprietary tools on the servers that needs to be managed by Puppet
- Puppet architecture is very complex
</pre>


## Chef Overview
<pre>
- is a configuration management tool
- it follows client/server architecture
- the domain specific language (DSL) - the automation language used by Chef
- the DSL used by Chef is Ruby ( scripting language )
- Chef installation is very complex and time consuming as Puppet
- Chef provides loads of tools, hence its very powerful and confusing
- learning curve is quite steep
- uses proprietary tools on the servers that needs to be managed by chef
- chef architecture is very complex
</pre>

## Ansible Overview
<pre>
- is a configuration management tool
- it is agent-less
- easy to learn
- easy to install
- follows simple architecture
- ansible nodes
  - these are servers we can perform automation using ansible 
  - dependent softwares
    - Unix/Linux/Mac Server
      - Python
      - SSH Server
    - Windows Server
      - Powershell
      - WinRM
- Ansible Controller Machine
  - the machine where ansible is installed is called Ansible Controller Machine(ACM)
  - it could a laptop/desktop
  - officially Ansible is only supported on Linux machines, but it works in Unix/Mac
  - Windows machine can't be used as a Ansible Controller Machine
  - Windows machine can be managed by Ansible
- Inventory
  - is a plain text file which follows an INI style format
  - captures connectivity details, IP address/hostname, username, password, ssh-key's etc
- comes in 3 flavours
  1. Ansible core - open source variant supports only command line
  2. AWX - supports webconsole, opensource, built on top of Ansible core
  3. Red Hat Ansible Tower - enterprise commercial product, built on top of AWX 
</pre>

## Ansible Core
<pre>
- this is developed in Python by Michael Deehan
- Michael Deehan is a former employee of Red Hat
- Michael Deehan founded a company called Ansible Inc and developed Ansible core as an open source product
- perfect alternate to Puppet/Chef
- supports only command line
- very well documented open source product
- agent less
- can be installed in Linux, Unix and Mac
- can manage Windows, Linux, Mac, etc., ansible nodes
- doesn't support role based access ( can't create different types of ansible users )
- doesn't historial logging mechanism
</pre>

## AWX
<pre>
- is developed on top of Ansible core
- supports webconsole but no command line
- it can be installed on a centralized server within your organization
- can be accessed from web browser only
- supports role based access control
- supports logs for each playbook execution
- you don't get any support
- can't develop ansible playbook, you can only run them
- which means we need ansible core to develop/write playbook
</pre>

## Red Hat Ansible Tower
<pre>
- it is developed on top of AWX
- functionally AWX and Ansible Tower(Ansible Automation Platform) are same
- you will world-wide support from Red Hat (an IBM company)
- which means we need ansible core to develop/write playbook
</pre>

## Ansible Modules
<pre>
- ansible supports many built-in ansible modules to automate
- for instance 
  - file module helps in creating files and folders with specific permissions
  - copy module helps in copying from/to ACM to ansible nodes and vice versa
  - all unix/linux/mac ansible modules are developed as Python scripts
  - all windows ansible modules are developed as Powershell scripts
  - we can also write out own custom ansible modules, when there is no readily available module to automate certain rare stuffs
</pre>

## Ansible Plugins
<pre>
- ansible plugins helps us extend the core functionality of ansible
- for instance
  - become plugin helps us perform certain tasks as sudo(administrative) users
</pre>

## Ansible Roles
<pre>
- is way we could follow best practices and ensure our automation code can be reused across many ansible playbooks
- ansible roles can't be executed directly, while they can be invoked via ansible playbooks
- ansible roles can be downloaded and installed via ansible-galaxy tool
- we could also develop our own ansible role
- For example
  - we could develop an ansible role to install Oracle Database in Windows 2016/2019 Server, Ubuntu Linux, etc
</pre>

## Ansible Playbook
<pre>
- is a YAML file 
- it invokes bunch of Ansible module, roles in a particular order to automate configuration management activity
</pre>

## Ansible Collections
<pre>
- is a reusable code that has many different kinds of reusable code in ansible
- it could have one or more roles, custom modules, plugins, filters, etc.,
- it's a way we could package and distribute all the related playbooks, modules, plugins, etc in a single collection
</pre>


## Lab - Install Ansible Core in Ubuntu
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
```

## Lab - Prepare a custom docker image to use an ansible node
Pull TekTutor training repository
```
cd ~/devops-jan-2025
git pull
cd Day2/CustomAnsibleNodeDockerImage
ssh-keygen
cp ~/.ssh/id_rsa.pub authorized_keys
docker build -t tektutor/rocky-ansible-node:latest .
docker images
```

Create couple of containers
```
docker run -d --name rocky1 --hostname rocky1 -p 2001:22 -p 8001:80 tektutor/rocky-ansible-node:latest
docker run -d --name rocky2 --hostname rocky2 -p 2002:22 -p 8002:80 tektutor/rocky-ansible-node:latest
docker ps
```

Check if you are able to ssh into those containers ( it shouldn't prompt for password )
```
ssh -p 2001 root@localhost
exit
ssh -p 2002 root@localhost
```

Now create your first anisble playbook in a file called ping-playbook.yml
```
- name: This playbook helps to verify if ansible is able to communicate with the ansible nodes
  hosts: all
  tasks:
  - name: Ping ansible node
    ping
```

Now let's create a static inventory file ( file name is inventory )
```
[all]
rocky1 ansible_user=root ansible_port=2001 ansible_host=localhost ansible_private_key_file=~/.ssh/id_ed25519
rocky2 ansible_user=root ansible_port=2002 ansible_host=localhost ansible_private_key_file=~/.ssh/id_ed25519
```

The static inventory could also be refactored to avoid redundancy as shown below
```
[all]
rocky1 ansible_port=2001
rocky2 ansible_port=2002

[all:vars]
ansible_user=root 
ansible_host=localhost
ansible_private_key_file=~/.ssh/id_ed25519
```

Running an ansible ad-hoc command
```
ansible -i inventory all -m ping
ansible -i inventory rocky1 -m setup
```

Now, let's see if we are able to run the ansible playbook
```
cd ~/devops-jan-2025
git pull
cd Day2/playbooks
ansible-playbook -i inventory ping-playbook.yml
```
