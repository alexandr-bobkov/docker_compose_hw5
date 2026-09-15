terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  folder_id = "b1gm00agl8bt1c2vab85"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "devops-prod-vm"
  platform_id = "standard-v2"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    # Явно указываем пользователя ubuntu и содержимое ключа id_rsa.pub
    ssh-keys = "ubuntu:${file("~/.ssh/netology_id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "netology-network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}
