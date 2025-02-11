#!/bin/bash

VM_NAME="archlinux"
MEMORY="10240"
CPU="host"
ISO="/home/ursus/Projects/arch_install/archlinux-2025.02.01-x86_64.iso"
DISK="/home/ursus/Projects/arch_install/archlinux.qcow2"
SIZE="20G"
BOOT_FROM_ISO="true"

display_config() {
	echo "
	░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀░█░█░█▀▄░█▀█░▀█▀░▀█▀░█▀█░█▀█
	░█░░░█░█░█░█░█▀▀░░█░░█░█░█░█░█▀▄░█▀█░░█░░░█░░█░█░█░█
	░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀
	"
	echo "VM name: ${VM_NAME}"
	echo "Memory: ${MEMORY} MB"
	echo "CPU model: ${CPU}"
	echo "ISO path: ${ISO}"
	echo "Disk path: ${DISK}"
	echo "Disk size: ${SIZE}"
	echo "Boot from ISO: ${BOOT_FROM_ISO}"
}

modify_config() {
	while true; do
		echo "What do you want to modify?"
		echo "1. VM name"
		echo "2. Memory"
		echo "3. CPU model"
		echo "4. ISO path"
		echo "5. Disk path"
		echo "6. Disk size"
		echo "7. Boot from ISO"
		echo "8. Done"
		read -p "Enter your choise (1-8): " choice


		case $choice in
			1) read -p "Enter new VM name: " VM_NAME
				;;
			2) read -p "Enter new Memory (MB): " MEMORY
				;;
			3) read -p "Enter new CPU model: " CPU
				;;
			4) read -p "Enter new ISO path: " ISO
				;;
			5) read -p "Enter new Disk path: " DISK
				;;
			6) read -p "Enter new Disk size: " SIZE
				;;
			7) read -p "Enter new Boot from ISO: " BOOT_FROM_ISO
				;;
			8) break
				;;
			*) echo "Invalid choise. Please enter a new number between 1 and 8."
				;;
		esac
	done
}

update_script() {
	sed -i "s/^VM_NAME=\"[^\"]*\"/VM_NAME=\"${VM_NAME}\"/g" "$0"
	sed -i "s/^MEMORY=\"[^\"]*\"/MEMORY=\"${MEMORY}\"/g" "$0"
	sed -i "s/^CPU=\"[^\"]*\"/CPU=\"${CPU_MODEL}\"/g" "$0"
	sed -i "s/^ISO=\"[^\"]*\"/ISO=\"${ISO}\"/g" "$0"
	sed -i "s/^DISK=\"[^\"]*\"/DISK=\"${DISK}\"/g" "$0"
	sed -i "s/^SIZE=\"[^\"]*\"/SIZE=\"${SIZE}\"/g" "$0"
	sed -i "s/^BOOT_FROM_ISO=\"[^\"]*\"/BOOT_FROM_ISO=\"${BOOT_FROM_ISO}\"/g" "$0"
}

display_config

read -p "Do you want to modify the configuration? (y/n): " modify
if [[ "$modify" == "y" ]]; then
	modify_config
	udate_script
	echo "Configuration updated."
	display_config
fi

QEMU_COMMAND="qemu-system-x86_64"
QEMU_OPTIONS=" \
	-enable-kvm \
	-m ${MEMORY} \
	-cpu ${CPU} \
	-drive file=${DISK},if=virtio \
	-net nic,model=virtio \
	-net user"

if [ "${BOOT_FROM_ISO}" = "true" ]; then
	QEMU_OPTIONS="${QEMU_OPTIONS} -cdrom ${ISO} -boot d"
fi

if [ ! -f "${DISK}" ]; then
	echo "Creating new disk image at ${DISK}..."
	qemu-img create -f qcow2 "${DISK}" ${SIZE}
	if [ $? -ne 0 ]; then
		echo "Error creating disk image. Exiting"
		exit 1
	fi
fi


echo "Starting ${VM_NAME} VM"
${QEMU_COMMAND} ${QEMU_OPTIONS}

echo "VM stopped"

# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 2048 \
#   -cpu host \
#   -cdrom  \
#   -drive file=,if=virtio \
#   -net nic,model=virtio \
#   -net user \
#   -boot d
