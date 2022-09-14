#include "string.h"
#include "stdlib.h"
#include "mxsock.h"
#pragma comment(linker,"/SUBSYSTEM:Console /ENTRY:Entry") 
#pragma comment(lib, "mx32.lib")
#pragma comment(lib, "mxsock.lib")

void __stdcall msgbox(char *param1, char *param2);
void __stdcall ExitProcess(int ExitCode);
void __stdcall Sleep(unsigned int milliseconds);
void __stdcall print(char* line);
char* __stdcall GetCommandLine();
int __stdcall GetTimer();
int __stdcall _malloc(int size);

void print_int(int a) {
	char buf[32];
	memset(buf, 0, sizeof buf);
	itoa(a, buf, 10);
	print(buf);
}
void print_hex(int a) {
	char buf[32];
	memset(buf, 0, sizeof buf);
	itoa(a, buf, 16);
	print(buf);
}
int strpos(char *line1, char* line2) {
	int i;
	if (strlen(line1) <= 0) return -1;
	for (i = 0; i < strlen(line1); i++) {
		if (line1[i] == line2[0]) return i;
	}
	return -1;
}

void Entry()
{
	int i,j,z;
	int answer, req_max; 
	char opt[1];
	int res = 0;
	int count = 4;
	unsigned short id = 0x1337;
	char host[32], param[32];
	int pos, bip;
	struct sockaddr_in server;
	int received = 0;
	int sock;
	int start_time;
	char data[] = "abcdefghijklmnopqrstuvwxyz012345";
	char *buf = _malloc(0x1000);
	char packet[128];
	char sender_ip_str[16];
	int packet_len = 8 + sizeof data;
	unsigned char cttl;
	int ttl,end_time,way_time;
	if (strlen(GetCommandLine()) == 0) ExitProcess(0);
	memset(host, 0, sizeof host);
	memset(param, 0, sizeof param);
	memcpy(host, GetCommandLine(), strlen(GetCommandLine()));

	// look for another param
	pos = strpos(host, " ");
	if (pos != -1) {
		memcpy(param, host + pos + 1, strlen(host) - pos - 1);
		if (strlen(param) > 0) {
			if (strcmp(param, "/t") ==0) count = 10000000;
			if (strcmp(param, "-t") == 0) count = 10000000;
		}
		host[pos] = 0;
	}

	bip = str2bip(host);

	print("\r\nPinging ");
	print(host);
	print(" with 32 bytes of data:\r\n");



	sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);

	// prepare sock struct
	server.sin_family = AF_INET;
	server.sin_port = 0;
	memcpy(&server.sin_addr, &bip, 4);

	res = connect(sock, (char*)&server, 18);

	opt[0] = 128;
	setsockopt(sock, IPPROTO_IP, IP_TTL, opt, 16);

	// prepare ICMP packet
	memset(packet, 0, sizeof packet);
	packet[0] = 8;					// ICMP_ECHO;
	packet[1] = 0;					// code
	packet[2] = 0; packet[3] = 0;	// checksum
	memcpy(packet + 4, &id, 2);
	packet[6] = 0; packet[7] = 0;	// sequence number
	memcpy(packet + 8, data, sizeof data);
	
	for (j = 0; j < count; j++) {
		send(sock, packet, packet_len, 0);
		start_time = GetTimer();
		req_max = 200;
		answer = 0;
		for (i = 0; i<req_max; i++) {
			memset(buf, 0, sizeof buf);
			Sleep(1);
			received = recv(sock, buf, 1024, MSG_DONTWAIT);
			//if (received>0) break;
			if (received > 0 && received < 1024) {
				// IP header length
				unsigned char clen = buf[0];
				int len = clen & 0xF;
				len = len << 2;

				// Check packet length
				received -= len;
				received -= 8;		// -= sizeof.ICMP_header
				if (received > 0) {
					// check hdr
					// chk ICMP type == ICMP_ECHOREPLY
					if (buf[len] == 0)  {
						unsigned short id_from_sender;
						memcpy(&id_from_sender, buf + len + 4, 2);
						z = id_from_sender;
						if (id_from_sender == id)  {
							// here print sender ip

							unsigned int sender_ip;
							// get sender ip
							memcpy(&sender_ip, buf + 12, 4);
							ip2str(sender_ip, sender_ip_str);

							print("Reply from ");
							print(sender_ip_str);					// <- sender IP

							// ttl = 8 (ipv4 hdr)
							// sender ip 12
							if (strcmp(data, buf + len + 8) == 0) {
								// get ttl
								end_time = GetTimer();
								way_time = (end_time - start_time)*3;
								if (way_time == 0) way_time = 1;
								cttl = buf[8];
								ttl = cttl;						// <- TTL

								print(": bytes=32");
								print(" time=");
								print_int(way_time);
								print("ms TTL=");
								print_int(ttl);
								print("\r\n");
								if (j+1!=count) Sleep(800);
								answer = 1;
							}
							break;
						}
					}
					// TTL exceeded? type == ICMP_TIMXCEED
					if (buf[len] == 11)  {
						answer = 2;
						break;
					}
				}
			}
		}
		if (i >= req_max && answer == 0) {
			print("Request timed out.\r\n");
		}
		else {
			if (answer != 1) {
				print("PING: transmit failed. General failure.\r\n");
			}
		}
	}

	print("\r\n");
	ExitProcess(0);
}
