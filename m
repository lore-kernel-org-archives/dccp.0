From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Tue, 06 Mar 2007 16:12:19 +0000
Subject: [PATCH 2/2][DCCP]: Set RTO for newly created child socket
Message-Id: <39e6f6c70703060812pf5dd272h5b7870978d364b18@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_164563_30954705.1173197539111"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_164563_30954705.1173197539111
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This mirrors a recent change in tcp_open_req_child, whereby the icsk_rto of the
newly created child socket was not set (but rather on the parent socket). Same
fix for DCCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

------=_Part_164563_30954705.1173197539111
Content-Type: text/x-patch; 
	name=0002-DCCP-Set-RTO-for-newly-created-child-socket.patch; 
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eyyjgqgk
Content-Disposition: attachment; filename="0002-DCCP-Set-RTO-for-newly-created-child-socket.patch"

RnJvbSAyZDUzOTY4NzkxYjczMmNiYTQyYzNmZjJjMzcxMDYwYTM0OWRhMmQ3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBHZXJyaXQgUmVua2VyIDxnZXJyaXRAZXJnLmFiZG4uYWMudWs+
CkRhdGU6IFR1ZSwgNiBNYXIgMjAwNyAxMzowNTowOCAtMDMwMApTdWJqZWN0OiBbUEFUQ0hdIFtE
Q0NQXTogU2V0IFJUTyBmb3IgbmV3bHkgY3JlYXRlZCBjaGlsZCBzb2NrZXQKClRoaXMgbWlycm9y
cyBhIHJlY2VudCBjaGFuZ2UgaW4gdGNwX29wZW5fcmVxX2NoaWxkLCB3aGVyZWJ5IHRoZSBpY3Nr
X3J0byBvZiB0aGUKbmV3bHkgY3JlYXRlZCBjaGlsZCBzb2NrZXQgd2FzIG5vdCBzZXQgKGJ1dCBy
YXRoZXIgb24gdGhlIHBhcmVudCBzb2NrZXQpLiBTYW1lCmZpeCBmb3IgRENDUC4KClNpZ25lZC1v
ZmYtYnk6IEdlcnJpdCBSZW5rZXIgPGdlcnJpdEBlcmcuYWJkbi5hYy51az4KU2lnbmVkLW9mZi1i
eTogQXJuYWxkbyBDYXJ2YWxobyBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogbmV0L2Rj
Y3AvbWluaXNvY2tzLmMgfCAgICAyICstCiAxIGZpbGVzIGNoYW5nZWQsIDEgaW5zZXJ0aW9ucygr
KSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvZGNjcC9taW5pc29ja3MuYyBiL25l
dC9kY2NwL21pbmlzb2Nrcy5jCmluZGV4IDY2NTZiYjQuLjZkMjM1YjMgMTAwNjQ0Ci0tLSBhL25l
dC9kY2NwL21pbmlzb2Nrcy5jCisrKyBiL25ldC9kY2NwL21pbmlzb2Nrcy5jCkBAIC0xMDMsNyAr
MTAzLDcgQEAgc3RydWN0IHNvY2sgKmRjY3BfY3JlYXRlX29wZW5yZXFfY2hpbGQoc3RydWN0IHNv
Y2sgKnNrLAogCiAJaWYgKG5ld3NrICE9IE5VTEwpIHsKIAkJY29uc3Qgc3RydWN0IGRjY3BfcmVx
dWVzdF9zb2NrICpkcmVxID0gZGNjcF9yc2socmVxKTsKLQkJc3RydWN0IGluZXRfY29ubmVjdGlv
bl9zb2NrICpuZXdpY3NrID0gaW5ldF9jc2soc2spOworCQlzdHJ1Y3QgaW5ldF9jb25uZWN0aW9u
X3NvY2sgKm5ld2ljc2sgPSBpbmV0X2NzayhuZXdzayk7CiAJCXN0cnVjdCBkY2NwX3NvY2sgKm5l
d2RwID0gZGNjcF9zayhuZXdzayk7CiAJCXN0cnVjdCBkY2NwX21pbmlzb2NrICpuZXdkbXNrID0g
ZGNjcF9tc2sobmV3c2spOwogCi0tIAoxLjUuMC4yCgo=
------=_Part_164563_30954705.1173197539111--
