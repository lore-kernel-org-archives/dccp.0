From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 07 Jun 2007 20:13:54 +0000
Subject: Re: 'BUG: scheduling while atomic' during dccp transfer
Message-Id: <39e6f6c70706071313k4d321a37m7e5e87b8d76e119@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_25002_17142865.1181247234351"
List-Id: <dccp.vger.kernel.org>
References: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
In-Reply-To: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
To: dccp@vger.kernel.org

------=_Part_25002_17142865.1181247234351
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 6/7/07, Florian Westphal <fw@strlen.de> wrote:
> While transmitting data via dccp (Linux 2.6.21) I encountered this:
>
> BUG: scheduling while atomic: firefox-bin/0x10000100/6792
>  [<c02f8f4c>] schedule+0x43c/0x5c0
>  [<c029c3af>] skb_checksum+0x4f/0x2a0
>  [<c013818a>] handle_level_irq+0x7a/0xc0
>  [<c01145d6>] __cond_resched+0x16/0x40
>  [<c02f914a>] cond_resched+0x2a/0x40
>  [<c0151d8a>] __kmalloc+0x6a/0x80
>  [<d079e0ca>] ccid2_hc_tx_alloc_seq+0x4a/0xd0 [dccp_ccid2]
>  [<d079e67c>] ccid2_hc_tx_packet_sent+0x13c/0x170 [dccp_ccid2]
>  [<d079e540>] ccid2_hc_tx_packet_sent+0x0/0x170 [dccp_ccid2]
>  [<d07ab917>] dccp_write_xmit+0x207/0x300 [dccp]
>  [<d07ad667>] dccp_write_xmit_timer+0x37/0x40 [dccp]
>  [<c011e843>] run_timer_softirq+0x123/0x180
>  [<d07ad630>] dccp_write_xmit_timer+0x0/0x40 [dccp]
>  [<d07ad630>] dccp_write_xmit_timer+0x0/0x40 [dccp]
>  [<c011b522>] __do_softirq+0x42/0x90
>  [<c011b596>] do_softirq+0x26/0x30
>  [<c011b85a>] irq_exit+0x5a/0x60
>  [<c0105ced>] do_IRQ+0x3d/0x70
>  [<c011b228>] sys_gettimeofday+0x28/0x80
>  [<c01040db>] common_interrupt+0x23/0x28
>  [<c02f0000>] km_policy_expired+0x10/0x50
>  =======================
>
> Please CC me on replies, i'm not subscribed.
> Thanks, Florian.

Can you try with the attached patch?

- Arnaldo

------=_Part_25002_17142865.1181247234351
Content-Type: text/x-patch; name=dccp_ccid2_hc_tx_alloc_seq_GFP_ATOMIC.patch; 
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f2no2vij
Content-Disposition: attachment; filename="dccp_ccid2_hc_tx_alloc_seq_GFP_ATOMIC.patch"

ZGlmZiAtLWdpdCBhL25ldC9kY2NwL2NjaWRzL2NjaWQyLmMgYi9uZXQvZGNjcC9jY2lkcy9jY2lk
Mi5jCmluZGV4IDI0OGQyMGYuLmZiNTcxMGUgMTAwNjQ0Ci0tLSBhL25ldC9kY2NwL2NjaWRzL2Nj
aWQyLmMKKysrIGIvbmV0L2RjY3AvY2NpZHMvY2NpZDIuYwpAQCAtODMsOCArODMsNyBAQCBzdGF0
aWMgdm9pZCBjY2lkMl9oY190eF9jaGVja19zYW5pdHkoY29uc3Qgc3RydWN0IGNjaWQyX2hjX3R4
X3NvY2sgKmhjdHgpCiAjZGVmaW5lIGNjaWQyX2hjX3R4X2NoZWNrX3Nhbml0eShoY3R4KQogI2Vu
ZGlmCiAKLXN0YXRpYyBpbnQgY2NpZDJfaGNfdHhfYWxsb2Nfc2VxKHN0cnVjdCBjY2lkMl9oY190
eF9zb2NrICpoY3R4LCBpbnQgbnVtLAotCQkJCSBnZnBfdCBnZnApCitzdGF0aWMgaW50IGNjaWQy
X2hjX3R4X2FsbG9jX3NlcShzdHJ1Y3QgY2NpZDJfaGNfdHhfc29jayAqaGN0eCwgaW50IG51bSkK
IHsKIAlzdHJ1Y3QgY2NpZDJfc2VxICpzZXFwOwogCWludCBpOwpAQCAtOTUsNyArOTQsNyBAQCBz
dGF0aWMgaW50IGNjaWQyX2hjX3R4X2FsbG9jX3NlcShzdHJ1Y3QgY2NpZDJfaGNfdHhfc29jayAq
aGN0eCwgaW50IG51bSwKIAkJcmV0dXJuIC1FTk9NRU07CiAKIAkvKiBhbGxvY2F0ZSBidWZmZXIg
YW5kIGluaXRpYWxpemUgbGlua2VkIGxpc3QgKi8KLQlzZXFwID0ga21hbGxvYyhzaXplb2YoKnNl
cXApICogbnVtLCBnZnApOworCXNlcXAgPSBrbWFsbG9jKHNpemVvZigqc2VxcCkgKiBudW0sIEdG
UF9BVE9NSUMpOwogCWlmIChzZXFwID09IE5VTEwpCiAJCXJldHVybiAtRU5PTUVNOwogCkBAIC0y
OTgsNyArMjk3LDcgQEAgc3RhdGljIHZvaWQgY2NpZDJfaGNfdHhfcGFja2V0X3NlbnQoc3RydWN0
IHNvY2sgKnNrLCBpbnQgbW9yZSwgdW5zaWduZWQgaW50IGxlbikKIAkJaW50IHJjOwogCiAJCWNj
aWQyX3ByX2RlYnVnKCJhbGxvY2F0aW5nIG1vcmUgc3BhY2UgaW4gaGlzdG9yeVxuIik7Ci0JCXJj
ID0gY2NpZDJfaGNfdHhfYWxsb2Nfc2VxKGhjdHgsIENDSUQyX1NFUUJVRl9MRU4sIEdGUF9LRVJO
RUwpOworCQlyYyA9IGNjaWQyX2hjX3R4X2FsbG9jX3NlcShoY3R4LCBDQ0lEMl9TRVFCVUZfTEVO
KTsKIAkJQlVHX09OKHJjKTsgLyogWFhYIHdoYXQgZG8gd2UgZG8/ICovCiAKIAkJbmV4dCA9IGhj
dHgtPmNjaWQyaGN0eF9zZXFoLT5jY2lkMnNfbmV4dDsKQEAgLTc3MSw3ICs3NzAsNyBAQCBzdGF0
aWMgaW50IGNjaWQyX2hjX3R4X2luaXQoc3RydWN0IGNjaWQgKmNjaWQsIHN0cnVjdCBzb2NrICpz
aykKIAloY3R4LT5jY2lkMmhjdHhfc2VxYnVmYyAgID0gMDsKIAogCS8qIFhYWCBpbml0IH4gdG8g
d2luZG93IHNpemUuLi4gKi8KLQlpZiAoY2NpZDJfaGNfdHhfYWxsb2Nfc2VxKGhjdHgsIENDSUQy
X1NFUUJVRl9MRU4sIEdGUF9BVE9NSUMpICE9IDApCisJaWYgKGNjaWQyX2hjX3R4X2FsbG9jX3Nl
cShoY3R4LCBDQ0lEMl9TRVFCVUZfTEVOKSAhPSAwKQogCQlyZXR1cm4gLUVOT01FTTsKIAogCWhj
dHgtPmNjaWQyaGN0eF9zZW50CSA9IDA7Cg==
------=_Part_25002_17142865.1181247234351--
