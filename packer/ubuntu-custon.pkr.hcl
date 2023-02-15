source "googlecompute" "ubuntu-custom" {
      project_id = "groovy-autumn-377820"
      source_image_family = "ubuntu-2004-lts"
      image_name = "nginx-ubuntu-2004-{{timestamp}}"
      communicator = "ssh"
      ssh_username = "elijah"
      zone = "us-central1-c"
      machine_type = "n1-f1-micro"
      disk_size = 10
      network_interface = "network = default, access_config = {}"
}

  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt update",
        "sudo apt install -y nginx",
	"sudo apt install -y git",
        "sudo systemctl start nginx",
        "sudo systemctl enable nginx"
      ]
    }
  ]
}
