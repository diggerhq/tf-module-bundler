provider "aws" {
  region = "{{ aws_region }}"
  {% if not for_local_run %} 
    {% if assume_role_arn %}
  assume_role {
    role_arn="{{assume_role_arn}}"
    external_id="{{assume_role_external_id}}"
  }
    {% else %}
  access_key = "{{aws_key}}"
  secret_key = "{{aws_secret}}"
    {% endif %}  
  {% endif %}
}

{% for module in modules %}
  {% if module.type == "vpc" %}
module "network" {
  source = "./{{ module.module_name }}"
  network_name = "{{module.network_name}}"
  region = "{{ aws_region }}"
  tags = {
    digger_identifier = "{{module.network_name}}"
  }
} 
output "network" {
  value = module.network
}
  {% elif module.type == "container" %}
module "{{ module.module_name }}" {
  source = "./{{ module.module_name }}"
  vpc_id = module.network.vpc_id
  app = "{{module.aws_app_identifier}}"
  ecs_cluster_name = "{{module.aws_app_identifier}}"
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
  container_port = {{module.container_port}}
  region = "{{ aws_region }}"
  monitoring_enabled = false
  alarms_sns_topic_arn = ""
  tags = {
    digger_identifier = "{{module.aws_app_identifier}}"
  }
}

output "{{ module.module_name }}" {
  value = module.{{ module.module_name }}
}

  {% elif module.type == "resource" %}
module "{{ module.module_name }}" {
  source = "./{{ module.module_name }}"
  vpc_id = module.network.vpc_id
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
  security_groups = flatten({{ security_groups | join(", ") or []}})
  aws_app_identifier = "{{module.aws_app_identifier}}"
  region = "{{ aws_region }}"
  tags = {
    digger_identifier = "{{module.aws_app_identifier}}"
  }
}

output "{{ module.module_name }}" {
  value = module.{{ module.module_name }}
}
  {% endif %}
{% endfor %}


