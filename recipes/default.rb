#
# Cookbook:: aosNexus
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'apt'

docker_service 'default' do
    insecure_registry '10.118.40.51:8083'
    action [:create,:start]
end

docker_registry 'pocNexus' do
   serveraddress '10.118.40.51:8083'
   username 'admin'
   password 'admin123'
   email 'test@deloitte.com'
end

# Pull tomcat latest image
docker_image 'aos_tomcat' do
    repo '10.118.40.51:8083/aos_tomcat_built'
    action :pull
end

# Pull postgres latest image
docker_image 'aos_postgres' do
    repo '10.118.40.51:8083/aos_postgres'
    action :pull
end

# Run postgres container exposing ports
docker_container 'aos_postgres' do
    host_name 'aos_postgres'
    repo '10.118.40.51:8083/aos_postgres'
    port '5432:5432'
    action :run_if_missing
end

# Run tomcat container exposing ports
docker_container 'aos_tomcat' do
    host_name 'aosweb.aos.com'
    repo '10.118.40.51:8083/aos_tomcat_built'
    port ['8000:8000','8009:8009']
    extra_hosts ["DockerServer:#{node['ipaddress']}","aos_postgres:#{node['ipaddress']}"]
    links ['aos_postgres:aos_postgres']
    action :run_if_missing
end