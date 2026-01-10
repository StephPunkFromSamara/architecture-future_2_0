terraform {
  required_version = ">= 1.14"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177"
    }
  }
}



provider "yandex" {
  token = "service-account-key-new.json"
  cloud_id  = var.cloud_id              # ID облака
  folder_id = var.folder_id             # ID папки
  zone      = var.zone                  # ru-central1-a
}

# ==== Сеть ====
resource "yandex_vpc_network" "main" {
  name = "main-network2"  # уникальное имя для новой сети
}

resource "yandex_vpc_subnet" "main" {
  name       = "main-subnet-2"  # уникальное имя
  network_id = yandex_vpc_network.main.id
  zone       = var.zone
  v4_cidr_blocks = ["10.129.0.0/24"]
}
resource "yandex_resourcemanager_folder_iam_member" "terraform_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:aje7a4uorq0fmi3fkda2"
}
# ==== Виртуальная машина ====
resource "yandex_compute_instance" "vm" {
  name = var.vm_name
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      size         = 20
      image_id = "fd8498pb5smsd5ch4gid"   # корректное место для image_family
      type         = "network-hdd"
    }
    auto_delete = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}