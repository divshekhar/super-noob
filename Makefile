kernel_source_files := ${shell find kernel -name *.c}
kernel_object_files := ${patsubst kernel/%.c, build/kernel/%.o, ${kernel_source_files}}

x86_64_c_source_files := ${shell find kernel/src -name *.c}
x86_64_c_object_files := ${patsubst kernel/src/%.c, build/x86_64/%.o, ${x86_64_c_source_files}}

x86_64_asm_source_files := ${shell find boot/src -name *.asm}
x86_64_asm_object_files := ${patsubst boot/src/%.asm, build/x86_64/%.o, ${x86_64_asm_source_files}}

$(kernel_object_files): build/kernel/%.o : kernel/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I kernel/include -ffreestanding $(patsubst build/kernel/%.o, kernel/%.c, $@) -o $@

${x86_64_c_object_files}: build/x86_64/%.o : kernel/src/%.c
	mkdir -p ${dir $@} && \
	x86_64-elf-gcc -c -I kernel/include -ffreestanding ${patsubst build/x86_64/%.o, kernel/src/%.c, $@} -o $@

${x86_64_asm_object_files}: build/x86_64/%.o : boot/src/%.asm
	mkdir -p ${dir $@} && \
	nasm -f elf64 ${patsubst build/x86_64/%.o, boot/src/%.asm, $@} -o $@

x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)

.PHONY: build-x86_64
build-x86_64: ${kernel_object_files} ${x86_64_object_files}
	mkdir -p dist/x86_64 && .
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld ${x86_64_asm_object_files} && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso

