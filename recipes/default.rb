#
# Cookbook:: chef-rean-mysql
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
root_password = node['chef-rean-mysql']['root_password']
default_database = node['chef-rean-mysql']['default_database']
bash 'Install Java Open JDK 1.8' do
    user 'root'
    cwd '/tmp'
    code <<-EOH
    cd /tmp
    wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
    yum -y install ./mysql57-community-release-el7-7.noarch.rpm
    yum -y install mysql-community-server
    systemctl start mysqld 
    temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '#{root_password}'; flush privileges;" > reset_pass.sql
    mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql
    EOH
end

unless default_database.empty?
    bash 'Creating Default Database' do
        user 'root'
        cwd '/tmp'
        code <<-EOH
        mysql -uroot -p#{root_password} -e "CREATE DATABASE #{default_database}"
        EOH
    end
end    