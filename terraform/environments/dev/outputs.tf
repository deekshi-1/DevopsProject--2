output "web_public_ips" { value = module.compute.instance_public_ips }
output "vpc_id"         { value = module.networking.vpc_id }