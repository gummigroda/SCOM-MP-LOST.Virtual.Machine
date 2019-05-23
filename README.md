# LOST Virtual Machine - SCOM ManagementPack

This MP builds from the MP from Kevin Holman:  
https://blogs.technet.microsoft.com/kevinholman/2014/10/16/faq-how-can-i-tell-which-servers-are-physical-or-virtual-in-scom/

* It detects Windows operatingsystems running as guests hosted on
  * VMWare
  * Hyper-V
  * XEN
  * Proxmox
  * VirtualBox  
  
  and classifies them as 'Virtual Machines'

---

## Classes

* LOST.Virtual.Windows.VMWare.Computer.Class --> Computer being hosted by VMWare
* LOST.Virtual.Windows.HyperV.Computer.Class --> Computer being hosted by Hyper-V
* LOST.Virtual.Windows.Xen.Computer.Class --> Computer being hosted by Xen
* LOST.Virtual.Windows.Proxmox.Computer.Class --> Computer being hosted by Proxmox
* LOST.Virtual.Windows.VirtualBox.Computer.Class --> Computer being hosted by VirtualBox

## Groups

* LOST.Virtual.Windows.VMWare.Computers.Group --> Any Windows Computer running on a VMWare host
* LOST.Virtual.Windows.HyperV.Computers.Group --> Any Windows Computer running on a Hyper-V host
* LOST.Virtual.Windows.Xen.Computers.Group --> Any Windows Computer running on a Xen host
* LOST.Virtual.Windows.Proxmox.Computers.Group --> Any Windows Computer running on a Proxmox host
* LOST.Virtual.Windows.VirtualBox.Computers.Group --> Any Windows Computer running on a VirtualBox host

---

## Install

Download the file 'LOST.Virtual.Machine.mp' and import it as usually.

---

Don't install both Kevin's MP and this MP as the discoveries are somewhat the same.