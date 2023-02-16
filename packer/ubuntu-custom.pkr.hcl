source "googlecompute" "ubuntu-custom" {
      project_id = "groovy-autumn-377820"
      source_image_family = "ubuntu-2004-lts"
      image_name = "nginx-ubuntu-custom"
      communicator = "ssh"
      ssh_username = "elijah"
      zone = "us-central1-c"
      disk_size = 10
      tags = ["custom"]
}

build {
  sources = ["sources.googlecompute.ubuntu-custom"]
  provisioner "file" {
    source = "./assets/nginx/default.conf"
    destination = "/tmp/default.conf"
  }
  provisioner "shell" {
    inline = [
        "sudo apt update",
        "sudo apt install -y nginx",
	"sudo apt install -y git",
	"sudo cp /tmp/default.conf /etc/nginx/default_template.conf",
        "sudo systemctl start nginx",
        "sudo systemctl enable nginx"
      ]
  }
}

