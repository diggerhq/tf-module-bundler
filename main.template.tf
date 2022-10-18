provider "aws" {
  region = "{{ variables.aws_region }}"
  {% if not for_local_run % } 
    {% if assume_role_arn %}
  assume_role {
    role_arn="{{variables.assume_role_arn}}"
    external_id="{{variables.assume_role_external_id}}"
  }
    {% else %}
  access_key = "{{variables.aws_access_key}}"
  secret_key = "{{variables.aws_secret_key}}"
    {% endif %}  
  {% endif %}
}

{% for module in modules %}
    {% if module.type == "vpc" %}
{{ 
module "network-{{module.variables.network_name}}" {
  source = "{{ module.path_to_module }}"
  network_name = "{{module.variables.network_name}}"
  tags = {
    digger_identifier = "{{aws_app_identifier}}"
  }
} 
}}
     {% elif module.type == "container" %}
{{ 

module "container-{{module.variables.aws_app_identifier}}" {
  source = "{{ module.path_to_module }}"
  vpc_id = module.network.vpc_id
  app = "{{module.variables.aws_app_identifier}}"
  ecs_cluster_name = "{{module.variables.aws_app_identifier}}"
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
  monitoring_enabled = false
  alarms_sns_topic_arn = ""
  tags = {
    digger_identifier = "{{aws_app_identifier}}"
}
}

}}
    {% endif %}
{% endfor %}


