.intel_syntax noprefix
.global _start

.section .text

_start:
	# Open socket
	mov rdi, 2
	mov rsi, 1
	mov rax, 0x29
	syscall
	mov socketfd, rax

	# Bind
	sub rsp, 16 # sockaddr for bind()

	# Initialize sockaddr structure
	mov word ptr [rsp], 2
	mov word ptr [rsp + 2], 0x5000
	mov dword ptr [rsp + 4], 0
	mov qword ptr [rsp + 8], 8
	mov rsi, rsp
	mov rdx, 16
	mov rdi, socketfd
	mov rax, 0x31
	syscall

	add rsp, 16

	# Listen
	mov rdi, socketfd
	mov rsi, 0
	mov rax, 0x32
	syscall

	# Accept
	mov rdi, socketfd
	mov rsi, 0
	mov rdx, 0
	mov rax, 0x2B
	syscall
	mov tun, rax

	# Read
	mov rdi, tun
	lea rsi, read_buffer
	mov rdx, 1024
	mov rax, 0
	syscall

	# Open
	lea rdi, [read_buffer + 4]
	movb [rdi + 16], 0
	mov rsi, 0
	mov rax, 2
	syscall
	mov ffd, rax

	# Read
	mov rdi, ffd
	lea rsi, file
	mov rdx, 1024
	mov rax, 0
	syscall
	mov filelen, rax

	# Close file
	mov rdi, ffd
	mov rax, 3
	syscall

	# Write response
	mov rdi, tun
	lea rsi, response
	mov rdx, 19
	mov rax, 1
	syscall

	# Write
	mov rdi, tun
	lea rsi, file
	mov rdx, filelen
	mov rax, 1
	syscall

	# Close
	mov rdi, tun
	mov rax, 3
	syscall

	# Exit
	mov rdi, 0
	mov rsi, 0
	mov rax, 0x3c
	syscall

.section .data
	response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
	read_buffer: .space 1024
	file: .space 1024
	filelen: .quad 0
	tun: .quad 0
	socketfd: .quad 0
	ffd: .quad 0
