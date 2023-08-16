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
    count = (length(var.SCRIPTs) > 0 ?
            length(var.SCRIPTs) : 0)

    template = <<-EOF
    ${var.SCRIPTs[count.index].PRE_COMMAND}
    EOF
}

data "template_file" "POST_COMMAND_SCRIPT" {
    count = (length(var.SCRIPTs) > 0 ?
            length(var.SCRIPTs) : 0)

    template = <<-EOF
    ${var.SCRIPTs[count.index].POST_COMMAND}
    EOF
}

resource "null_resource" "EXECUTE_SCRIPT" {
    count = (length(var.SCRIPTs) > 0 ?
            length(var.SCRIPTs) : 0)

    triggers = {
        always_run      = try("${var.SCRIPTs[count.index].ALWAYS}" == true ? timestamp() : null, null)
        PRE_COMMAND_SCRIPT = try("${data.template_file.SCRIPT[count.index].rendered}", null)
        VARAIANT        = try(join(",", "${var.SCRIPTs[count.index].VARIANTs}"), [])
        NAME            = try(file("${var.SCRIPTs[count.index].NAME}"), null)
        POST_COMMAND_SCRIPT = try("${data.template_file.SCRIPT[count.index].rendered}",null)
    }

    provisioner "local-exec" {
        command = <<-EOF
        %{ if "${self.triggers.PRE_COMMAND_SCRIPT}" != null ~}
        bash ${data.template_file.PRE_COMMAND_SCRIPT[count.index]}
        %{ endif ~}
        %{ if length("${self.triggers.VARIANTs}") > 0 ~}
            %{ for VARIANT in "${var.SCRIPTs[count.index].VARIANTs}" ~}
            export ${VARIANT}
            %{ endfor ~}
        %{ endif ~}
        %{ if "${self.triggers.NAME}" != null ~}
            bash "${var.SCRIPTs[count.index].NAME}"
        %{ endif ~}
        %{ if "${self.triggers.POST_COMMAND_SCRIPT}" != null ~}
        bash ${data.template_file.POST_COMMAND_SCRIPT[count.index]}
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
#         VARAIANT        = try(join(",", "${each.value.VARIANTs}"), [])
#         NAME            = try(file("${each.value.NAME}"), null)
#         POST_COMMAND    = try("${each.value.PRE_COMMAND}", "")
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