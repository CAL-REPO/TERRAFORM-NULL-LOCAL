# Standard AWS Provider Block
terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }
}

data "template_file" "PRE_COMMAND_SCRIPT" {
    for_each = { for index, SCRIPT in var.SCRIPTs : index => SCRIPT }

    template = <<-EOF
    ${try("${base64encode("${each.value.PRE_COMMAND}")}", "")}
    EOF
}

data "template_file" "POST_COMMAND_SCRIPT" {
    for_each = { for index, SCRIPT in var.SCRIPTs : index => SCRIPT }

    template = <<-EOF
    ${try("${base64encode("${each.value.POST_COMMAND_SCRIPT}")}", "")}
    EOF
}

resource "null_resource" "EXECUTE_SCRIPT" {
    for_each = { for index, SCRIPT in var.SCRIPTs : index => SCRIPT }

    triggers = {
        always_run    = try(each.value.ALWAYS == true ? timestamp() : null, null)
        PRE_COMMAND   = try(data.template_file.PRE_COMMAND_SCRIPT[each.key].rendered, "")
        VARIANT       = try(join(",", each.value.VARIANTs), "")
        NAME          = try(file(each.value.NAME), null)
        POST_COMMAND  = try(data.template_file.POST_COMMAND_SCRIPT[each.key].rendered, "")
    }

    provisioner "local-exec" {
    command = <<-EOF
        %{ if self.triggers.PRE_COMMAND != "" ~}
            echo "${self.triggers.PRE_COMMAND}" | base64 --decode | bash -s
        %{ endif ~}
        %{ if self.triggers.VARIANT != "" ~}
            %{ for VARIANT in split(",", self.triggers.VARIANT) ~}
            export ${VARIANT}
            %{ endfor ~}
        %{ endif ~}
        %{ if self.triggers.NAME != null ~}
            bash "${self.triggers.NAME}"
        %{ endif ~}
        %{ if self.triggers.POST_COMMAND != "" ~}
            echo "${self.triggers.POST_COMMAND}" | base64 --decode | bash -s
        %{ endif ~}
    EOF 
    interpreter = ["bash", "-c"]
  }
}

# resource "null_resource" "EXECUTE_SCRIPT" {
#     for_each = { for index, SCRIPT in var.SCRIPTs : index => SCRIPT }

#     triggers = {
#         always_run      = try("${each.value.ALWAYS}" == true ? timestamp() : null, null)
#         PRE_COMMAND     = try("${each.value.PRE_COMMAND}", "")
#         VARAIANT        = try(join(",", "${each.value.VARIANTs}"), "")
#         NAME            = try(file("${each.value.NAME}"), null)
#         POST_COMMAND    = try("${each.value.POST_COMMAND}", "")
#     }

#     provisioner "local-exec" {
#         command = <<-EOF
#         ${each.value.PRE_COMMAND}
#         %{ if length("${each.value.VARIANTs}") > 0 ~}
#             %{ for VARIANT in "${each.value.VARIANTs}" ~}
#             export ${VARIANT}
#             %{ endfor ~}
#         %{ endif ~}
#         %{ if "${each.value.NAME}" != null ~}
#             bash "${each.value.NAME}"
#         %{ endif ~}
#         ${each.value.POST_COMMAND}
#         EOF
#         interpreter = ["bash", "-c"]
#     }
# }