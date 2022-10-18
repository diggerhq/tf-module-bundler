provider "aws" {
  region = "{{ aws_region }}"
  {% if not for_local_run %} 
    {% if assume_role_arn %}
  assume_role {
    role_arn="{{assume_role_arn}}"
    external_id="{{assume_role_external_id}}"
  }
    {% else %}
  access_key = "{{aws_access_key}}"
  secret_key = "{{aws_secret_key}}"
    {% endif %}  
  {% endif %}
}

{% for module in modules %}
  {% if module.type == "vpc" %}
module "network-{{module.network_name}}" {
  source = "./{{ module.name }}"
  network_name = "{{module.network_name}}"
  tags = {
    digger_identifier = "{{module.aws_app_identifier}}"
  }
} 
  {% elif module.type == "container" %}
module "container-{{module.aws_app_identifier}}" {
  source = "./{{ module.name }}"
  vpc_id = module.network.vpc_id
  app = "{{module.aws_app_identifier}}"
  ecs_cluster_name = "{{module.aws_app_identifier}}"
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
  monitoring_enabled = false
  alarms_sns_topic_arn = ""
  tags = {
    digger_identifier = "{{module.aws_app_identifier}}"
  }
}
  {% endif %}
{% endfor %}


