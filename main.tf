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

resource "null_resource" "EXECUTE_APPLY_SCRIPT" {
    for_each = { for index, SCRIPT in var.APPLY_SCRIPTs : index => SCRIPT }

    triggers = {
        always_run    = try("${each.value.ALWAYS}" == true ? timestamp() : null, null)
        PRE_COMMAND   = try("${each.value.PRE_COMMAND}", "")
        VARIANT       = try(join(",", "${each.value.VARIANTs}"), "")
        NAME          = try(file("${each.value.NAME}"), null)
        POST_COMMAND  = try("${each.value.POST_COMMAND}", "")
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF
            %{ if self.triggers.PRE_COMMAND != null ~}
                ${self.triggers.PRE_COMMAND}
            %{ endif ~}
            %{ if self.triggers.VARIANT != "" ~}
                %{ for VARIANT in split(",", "${self.triggers.VARIANT}") ~}
                export ${VARIANT}
                %{ endfor ~}
            %{ endif ~}
            %{ if self.triggers.NAME != null ~}
                bash "${self.triggers.NAME}"
            %{ endif ~}
            %{ if self.triggers.POST_COMMAND != null ~}
                ${self.triggers.POST_COMMAND}
            %{ endif ~}
        EOF 
    }
}

resource "null_resource" "EXECUTE_CREATE_FILE" {
    for_each = { for index, FILE in var.CREATE_FILEs : index => FILE }

    triggers = {
        always_run  = try("${each.value.ALWAYS}" == true ? timestamp() : null, null)
        TYPE        = try("${each.value.TYPE}", "utf-8")
        FILENAME    = "${each.value.FILENAME}"
        CONTENT     = try("${each.value.CONTENT}", "")
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF
            %{ if self.triggers.TYPE == "utf-8" ~}
                echo "${self.triggers.CONTENT}" > "${each.value.FILENAME}"
            %{ endif ~}
            %{ if self.triggers.TYPE == "base64" ~}
                echo ${base64encode("${self.triggers.CONTENT}")} | base64 -d > ${each.value.FILENAME}
            %{ endif ~}
            %{ if self.triggers.TYPE == "json" ~}
                echo ${jsonencode("${self.triggers.CONTENT}")} > "${each.value.FILENAME}"
            %{ endif ~}
        EOF
    }

}




# data "template_file" "DESTROY_PRE_COMMAND_SCRIPT" {
#     for_each = { for index, SCRIPT in var.DESTROY_SCRIPTs : index => SCRIPT }

#     template = <<-EOF
#         ${try("${base64encode("${each.value.PRE_COMMAND}")}", "")}
#     EOF
# }

# data "template_file" "DESTROY_POST_COMMAND_SCRIPT" {
#     for_each = { for index, SCRIPT in var.DESTROY_SCRIPTs : index => SCRIPT }

#     template = <<-EOF
#         ${try("${base64encode("${each.value.POST_COMMAND}")}", "")}
#     EOF
# }

# resource "null_resource" "EXECUTE_DESTROY_SCRIPT" {
#     for_each = { for index, SCRIPT in var.DESTROY_SCRIPTs : index => SCRIPT }

#     triggers = {
#         always_run    = try("${each.value.ALWAYS}" == true ? timestamp() : null, null)
#         PRE_COMMAND   = try(data.template_file.DESTROY_PRE_COMMAND_SCRIPT[each.key].rendered, "")
#         VARIANT       = try(join(",", "${each.value.VARIANTs}"), "")
#         NAME          = try(file("${each.value.NAME}"), null)
#         POST_COMMAND  = try(data.template_file.DESTROY_POST_COMMAND_SCRIPT[each.key].rendered, "")
#     }

#     provisioner "local-exec" {
#         when = destroy
#         interpreter = ["bash", "-c"]
#         command = <<-EOF
#             %{ if self.triggers.PRE_COMMAND != "" ~}
#                 echo "${self.triggers.PRE_COMMAND}" | base64 --decode | bash -s
#             %{ endif ~}
#             %{ if self.triggers.VARIANT != "" ~}
#                 %{ for VARIANT in split(",", self.triggers.VARIANT) ~}
#                 export ${VARIANT}
#                 %{ endfor ~}
#             %{ endif ~}
#             %{ if self.triggers.NAME != null ~}
#                 bash "${self.triggers.NAME}"
#             %{ endif ~}
#             %{ if self.triggers.POST_COMMAND != "" ~}
#                 echo "${self.triggers.POST_COMMAND}" | base64 --decode | bash -s
#             %{ endif ~}
#         EOF 
#     }
# }