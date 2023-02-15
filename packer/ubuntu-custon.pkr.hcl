{
  "builders": [
    {
      "type": "googlecompute",
      "project_id": "groovy-autumn-377820",
      "source_image_family": "ubuntu-2004-lts",
      "image_name": "nginx-ubuntu-2004-{{timestamp}}",
      "ssh_username": "elijah",
      "zone": "us-central1-c",
      "machine_type": "n1-standard-1"
    }
  ],

  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update",
        "sudo apt-get install -y nginx",
        "sudo systemctl start nginx",
        "sudo systemctl enable nginx"
      ]
    }
  ]
}
