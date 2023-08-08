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

resource "null_resource" "EXECUTE_SCRIPT" {
    for_each = { for index, SCRIPT in var.SCRIPTs : index => SCRIPT }

    triggers = {
        always_run  = try("${each.value.ALWAYS}" == true ? timestamp() : null, null)
        NAME        = file("${each.value.NAME}")
        VARAIANT    = try(join(",", "${each.value.VARIANTs}"), null)
    }

    provisioner "local-exec" {
        command = <<-EOF
        #!/bin/bash
        %{ if length("${each.value.VARIANTs}") > 0 ~}
            %{ for VARIANT in "${each.value.VARIANTs}" ~}
            export ${VARIANT}
            %{ endfor ~}
        %{ endif ~}
        bash "${each.value.NAME}"
        EOF
    }
}