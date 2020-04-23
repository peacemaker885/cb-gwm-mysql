mysql = data_bag_item('apps', 'cb-gwm-mysql')

execute 'apt-get-update' do
  command "apt-get update"
  action :run
  not_if "dpkg -l mysql-server-5.7"
end

directory "/data/prabt" do
  action :create
  recursive true
end

mysql_service 'prabt' do
  port '3306'
  version '5.7'
  data_dir '/data/prabt'
  bind_address '0.0.0.0'
  initial_root_password node['prabt']['mysql_root_password']
  action [:create, :start]
end

mysql_config 'prabt' do
  instance 'prabt'
  source 'audit2020.erb'
  config_name 'audit2020'
  notifies :restart, 'mysql_service[prabt]'
  action :create
end

# MySQL commands to replade database cookbook
execute 'create_database' do
    command "mysql -u root -p#{node['prabt']['mysql_root_password']} -h 127.0.0.1 -e 'create database if not exists #{mysql[node.chef_environment]['mysql']['prabt']['database']}'"
    retries 2
end

execute 'create_database_user' do
    command "mysql -u root -p#{node['prabt']['mysql_root_password']} -h 127.0.0.1 -e 'grant select,insert,update,delete on \ 
    #{mysql[node.chef_environment]['mysql']['prabt']['database']}.* to \
    #{mysql[node.chef_environment]['mysql']['prabt']['username']} identified by \"#{mysql[node.chef_environment]['mysql']['prabt']['password']}\"'"
end

Chef::Log.warn "mysql root password #{node['prabt']['server_root_password']}"
