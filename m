From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 29 Oct 2016 06:10:39 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <CAM_iQpX_xw35MUyd9aON5U=HmUoRafeoOF+_vSTHGYnrXd-CHg@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="001a114aca60b0d1ff053ffad639"
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
To: dccp@vger.kernel.org

--001a114aca60b0d1ff053ffad639
Content-Type: text/plain; charset=UTF-8

On Fri, Oct 28, 2016 at 5:40 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while running the syzkaller fuzzer:
>
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 4608 at kernel/sched/core.c:7724
> __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
> do not call blocking ops when !TASK_RUNNING; state=1 set at
> [<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
> kernel/sched/wait.c:178
> Modules linked in:
> CPU: 0 PID: 4608 Comm: syz-executor Not tainted 4.9.0-rc2+ #320
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff88006625f7a0 ffffffff81b46914 ffff88006625f818 0000000000000000
>  ffffffff84052960 0000000000000000 ffff88006625f7e8 ffffffff81111237
>  ffff88006aceac00 ffffffff00001e2c ffffed000cc4beff ffffffff84052960
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46914>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff81111237>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>  [<ffffffff8111132c>] warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:565
>  [<ffffffff811922fc>] __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
>  [<     inline     >] slab_pre_alloc_hook mm/slab.h:393
>  [<     inline     >] slab_alloc_node mm/slub.c:2634
>  [<     inline     >] slab_alloc mm/slub.c:2716
>  [<ffffffff81508da0>] __kmalloc_track_caller+0x150/0x2a0 mm/slub.c:4240
>  [<ffffffff8146be14>] kmemdup+0x24/0x50 mm/util.c:113
>  [<ffffffff8388b2cf>] dccp_feat_clone_sp_val.part.5+0x4f/0xe0
> net/dccp/feat.c:374
>  [<     inline     >] dccp_feat_clone_sp_val net/dccp/feat.c:1141
>  [<     inline     >] dccp_feat_change_recv net/dccp/feat.c:1141
>  [<ffffffff8388d491>] dccp_feat_parse_options+0xaa1/0x13d0 net/dccp/feat.c:1411
>  [<ffffffff83894f01>] dccp_parse_options+0x721/0x1010 net/dccp/options.c:128
>  [<ffffffff83891280>] dccp_rcv_state_process+0x200/0x15b0 net/dccp/input.c:644
>  [<ffffffff838b8a94>] dccp_v4_do_rcv+0xf4/0x1a0 net/dccp/ipv4.c:681
>  [<     inline     >] sk_backlog_rcv ./include/net/sock.h:872
>  [<ffffffff82b7ceb6>] __release_sock+0x126/0x3a0 net/core/sock.c:2044
>  [<ffffffff82b7d189>] release_sock+0x59/0x1c0 net/core/sock.c:2502
>  [<     inline     >] inet_wait_for_connect net/ipv4/af_inet.c:547
>  [<ffffffff8316b2a2>] __inet_stream_connect+0x5d2/0xbb0 net/ipv4/af_inet.c:617
>  [<ffffffff8316b8d5>] inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:656
>  [<ffffffff82b705e4>] SYSC_connect+0x244/0x2f0 net/socket.c:1533
>  [<ffffffff82b72dd4>] SyS_connect+0x24/0x30 net/socket.c:1514
>  [<ffffffff83fbf701>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209

Should be fixed the attached patch. I will verify it with your
reproducer tomorrow.

Thanks!

--001a114aca60b0d1ff053ffad639
Content-Type: text/plain; charset=US-ASCII; name="dccp.diff"
Content-Disposition: attachment; filename="dccp.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuut68p61

ZGlmZiAtLWdpdCBhL25ldC9kY2NwL2ZlYXQuYyBiL25ldC9kY2NwL2ZlYXQuYwppbmRleCAxNzA0
OTQ4Li5jOTBjYjM1IDEwMDY0NAotLS0gYS9uZXQvZGNjcC9mZWF0LmMKKysrIGIvbmV0L2RjY3Av
ZmVhdC5jCkBAIC0zNjcsMTEgKzM2NywxMSBAQCBzdGF0aWMgaW5saW5lIGludCBkY2NwX2ZlYXRf
bXVzdF9iZV91bmRlcnN0b29kKHU4IGZlYXRfbnVtKQogfQogCiAvKiBjb3B5IGNvbnN0cnVjdG9y
LCBmdmFsIG11c3Qgbm90IGFscmVhZHkgY29udGFpbiBhbGxvY2F0ZWQgbWVtb3J5ICovCi1zdGF0
aWMgaW50IGRjY3BfZmVhdF9jbG9uZV9zcF92YWwoZGNjcF9mZWF0X3ZhbCAqZnZhbCwgdTggY29u
c3QgKnZhbCwgdTggbGVuKQorc3RhdGljIGludCBkY2NwX2ZlYXRfY2xvbmVfc3BfdmFsKGRjY3Bf
ZmVhdF92YWwgKmZ2YWwsIHU4IGNvbnN0ICp2YWwsIHU4IGxlbiwgZ2ZwX3QgZmxhZ3MpCiB7CiAJ
ZnZhbC0+c3AubGVuID0gbGVuOwogCWlmIChmdmFsLT5zcC5sZW4gPiAwKSB7Ci0JCWZ2YWwtPnNw
LnZlYyA9IGttZW1kdXAodmFsLCBsZW4sIGdmcF9hbnkoKSk7CisJCWZ2YWwtPnNwLnZlYyA9IGtt
ZW1kdXAodmFsLCBsZW4sIGZsYWdzKTsKIAkJaWYgKGZ2YWwtPnNwLnZlYyA9PSBOVUxMKSB7CiAJ
CQlmdmFsLT5zcC5sZW4gPSAwOwogCQkJcmV0dXJuIC1FTk9CVUZTOwpAQCAtNDA0LDcgKzQwNCw4
IEBAIHN0YXRpYyB2b2lkIGRjY3BfZmVhdF92YWxfZGVzdHJ1Y3Rvcih1OCBmZWF0X251bSwgZGNj
cF9mZWF0X3ZhbCAqdmFsKQogCiAJaWYgKHR5cGUgPT0gRkVBVF9TUCAmJiBkY2NwX2ZlYXRfY2xv
bmVfc3BfdmFsKCZuZXctPnZhbCwKIAkJCQkJCSAgICAgIG9yaWdpbmFsLT52YWwuc3AudmVjLAot
CQkJCQkJICAgICAgb3JpZ2luYWwtPnZhbC5zcC5sZW4pKSB7CisJCQkJCQkgICAgICBvcmlnaW5h
bC0+dmFsLnNwLmxlbiwKKwkJCQkJCSAgICAgIGdmcF9hbnkoKSkpIHsKIAkJa2ZyZWUobmV3KTsK
IAkJcmV0dXJuIE5VTEw7CiAJfQpAQCAtNzM1LDcgKzczNiw3IEBAIHN0YXRpYyBpbnQgX19mZWF0
X3JlZ2lzdGVyX3NwKHN0cnVjdCBsaXN0X2hlYWQgKmZuLCB1OCBmZWF0LCB1OCBpc19sb2NhbCwK
IAlpZiAoZmVhdCA9PSBEQ0NQRl9DQ0lEICYmICFjY2lkX3N1cHBvcnRfY2hlY2soc3BfdmFsLCBz
cF9sZW4pKQogCQlyZXR1cm4gLUVPUE5PVFNVUFA7CiAKLQlpZiAoZGNjcF9mZWF0X2Nsb25lX3Nw
X3ZhbCgmZnZhbCwgc3BfdmFsLCBzcF9sZW4pKQorCWlmIChkY2NwX2ZlYXRfY2xvbmVfc3BfdmFs
KCZmdmFsLCBzcF92YWwsIHNwX2xlbiwgZ2ZwX2FueSgpKSkKIAkJcmV0dXJuIC1FTk9NRU07CiAK
IAlyZXR1cm4gZGNjcF9mZWF0X3B1c2hfY2hhbmdlKGZuLCBmZWF0LCBpc19sb2NhbCwgbWFuZGF0
b3J5LCAmZnZhbCk7CkBAIC0xMTM4LDcgKzExMzksNyBAQCBzdGF0aWMgdTggZGNjcF9mZWF0X2No
YW5nZV9yZWN2KHN0cnVjdCBsaXN0X2hlYWQgKmZuLCB1OCBpc19tYW5kYXRvcnksIHU4IG9wdCwK
IAkJICogICBvdGhlcndpc2Ugd2UgYWNjZXB0IHRoZSBwcmVmZXJyZWQgdmFsdWU7CiAJCSAqIC0g
ZWxzZSBpZiB3ZSBhcmUgdGhlIGNsaWVudCwgd2UgdXNlIHRoZSBmaXJzdCBsaXN0IGVsZW1lbnQu
CiAJCSAqLwotCQlpZiAoZGNjcF9mZWF0X2Nsb25lX3NwX3ZhbCgmZnZhbCwgdmFsLCAxKSkKKwkJ
aWYgKGRjY3BfZmVhdF9jbG9uZV9zcF92YWwoJmZ2YWwsIHZhbCwgMSwgR0ZQX0FUT01JQykpCiAJ
CQlyZXR1cm4gRENDUF9SRVNFVF9DT0RFX1RPT19CVVNZOwogCiAJCWlmIChsZW4gPiAxICYmIHNl
cnZlcikgewo=
--001a114aca60b0d1ff053ffad639--
