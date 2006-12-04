From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Dec 2006 21:56:50 +0000
Subject: [PATCH] DCCP: remove timeo from output.c
Message-Id: <5640c7e00612041356s6fbba9abvc1616e28a9619f4f@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22787_24118359.1165269410405"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22787_24118359.1165269410405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 12/5/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>                         } else {
>                                 err = dccp_wait_for_ccid(sk, skb, &timeo);
>                                 timeo = DCCP_XMIT_TIMEO;          /* <==== I think you mean this one */
>                         }
>

Yes I did mean that one
>
>
> |  Anyway feel free to write a patch or I might when I get home from work
> |  or tomorrow
> I'd be happy to see a patch - maybe several cases can be folded into one.
>
Sending as attachment to message as mailer will mangle here I think -
reproduced below inline but I know gmail will mangle for sure. Compile
tested only as at work but I think I understand this code pretty well
and simplifying only. Removes the need for your patch altogether.

commit ab874add9a959d5b8a74ea654ad3c463da621bc0
Author: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date:   Tue Dec 5 10:48:49 2006 +1300

This patch simplifies things a lot by removing timeo as not needed.

Other simplifications flow on from this such as removing constants.

As a result of this EAGAIN is not returned any more.

Inspired by Gerrit Renker

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 6888698..44829d6 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -80,8 +80,6 @@ extern void dccp_time_wait(struct sock *sk, int
state, int timeo);

 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */

-#define DCCP_XMIT_TIMEO 30000 /* Time/msecs for blocking transmit per packet */
-
 /* sysctl variables for DCCP */
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 400c30b..c4460f6 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -177,12 +177,11 @@ void dccp_write_space(struct sock *sk)
  * @sk: socket to wait for
  * @timeo: for how long
  */
-static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb,
-			      long *timeo)
+static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	DEFINE_WAIT(wait);
-	long delay;
+	unsigned long delay;
 	int rc;

 	while (1) {
@@ -190,8 +189,6 @@ static int dccp_wait_for_ccid(struct sock *sk,
struct sk_buff *skb,

 		if (sk->sk_err)
 			goto do_error;
-		if (!*timeo)
-			goto do_nonblock;
 		if (signal_pending(current))
 			goto do_interrupted;

@@ -199,12 +196,9 @@ static int dccp_wait_for_ccid(struct sock *sk,
struct sk_buff *skb,
 		if (rc <= 0)
 			break;
 		delay = msecs_to_jiffies(rc);
-		if (delay > *timeo || delay < 0)
-			goto do_nonblock;
-
 		sk->sk_write_pending++;
 		release_sock(sk);
-		*timeo -= schedule_timeout(delay);
+		schedule_timeout(delay);
 		lock_sock(sk);
 		sk->sk_write_pending--;
 	}
@@ -215,11 +209,8 @@ out:
 do_error:
 	rc = -EPIPE;
 	goto out;
-do_nonblock:
-	rc = -EAGAIN;
-	goto out;
 do_interrupted:
-	rc = sock_intr_errno(*timeo);
+	rc = -EINTR;
 	goto out;
 }

@@ -240,8 +231,6 @@ void dccp_write_xmit(struct sock *sk, int block)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
-	long timeo = DCCP_XMIT_TIMEO; 	/* If a packet is taking longer than
-					   this we have other issues */

 	while ((skb = skb_peek(&sk->sk_write_queue))) {
 		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
@@ -251,10 +240,8 @@ void dccp_write_xmit(struct sock *sk, int block)
 				sk_reset_timer(sk, &dp->dccps_xmit_timer,
 						msecs_to_jiffies(err)+jiffies);
 				break;
-			} else {
-				err = dccp_wait_for_ccid(sk, skb, &timeo);
-				timeo = DCCP_XMIT_TIMEO;
-			}
+			} else
+				err = dccp_wait_for_ccid(sk, skb);
 			if (err)
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}

------=_Part_22787_24118359.1165269410405
Content-Type: text/plain; name="remove_timeo.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="remove_timeo.diff"
X-Attachment-Id: f_evbf9eap

Y29tbWl0IGFiODc0YWRkOWE5NTlkNWI4YTc0ZWE2NTRhZDNjNDYzZGE2MjFiYzAKQXV0aG9yOiBJ
YW4gTWNEb25hbGQgPGlhbi5tY2RvbmFsZEBqYW5kaS5jby5uej4KRGF0ZTogICBUdWUgRGVjIDUg
MTA6NDg6NDkgMjAwNiArMTMwMAoKVGhpcyBwYXRjaCBzaW1wbGlmaWVzIHRoaW5ncyBhIGxvdCBi
eSByZW1vdmluZyB0aW1lbyBhcyBub3QgbmVlZGVkLgogICAgCk90aGVyIHNpbXBsaWZpY2F0aW9u
cyBmbG93IG9uIGZyb20gdGhpcyBzdWNoIGFzIHJlbW92aW5nIGNvbnN0YW50cy4KICAgIApBcyBh
IHJlc3VsdCBvZiB0aGlzIEVBR0FJTiBpcyBub3QgcmV0dXJuZWQgYW55IG1vcmUuCiAgICAKSW5z
cGlyZWQgYnkgR2Vycml0IFJlbmtlcgogICAgClNpZ25lZC1vZmYtYnk6IElhbiBNY0RvbmFsZCA8
aWFuLm1jZG9uYWxkQGphbmRpLmNvLm56PgoKZGlmZiAtLWdpdCBhL25ldC9kY2NwL2RjY3AuaCBi
L25ldC9kY2NwL2RjY3AuaAppbmRleCA2ODg4Njk4Li40NDgyOWQ2IDEwMDY0NAotLS0gYS9uZXQv
ZGNjcC9kY2NwLmgKKysrIGIvbmV0L2RjY3AvZGNjcC5oCkBAIC04MCw4ICs4MCw2IEBAIGV4dGVy
biB2b2lkIGRjY3BfdGltZV93YWl0KHN0cnVjdCBzb2NrICpzaywgaW50IHN0YXRlLCBpbnQgdGlt
ZW8pOwogCiAjZGVmaW5lIERDQ1BfUlRPX01BWCAoKHVuc2lnbmVkKSgxMjAgKiBIWikpIC8qIEZJ
WE1FOiB1c2luZyBUQ1AgdmFsdWUgKi8KIAotI2RlZmluZSBEQ0NQX1hNSVRfVElNRU8gMzAwMDAg
LyogVGltZS9tc2VjcyBmb3IgYmxvY2tpbmcgdHJhbnNtaXQgcGVyIHBhY2tldCAqLwotCiAvKiBz
eXNjdGwgdmFyaWFibGVzIGZvciBEQ0NQICovCiBleHRlcm4gaW50ICBzeXNjdGxfZGNjcF9yZXF1
ZXN0X3JldHJpZXM7CiBleHRlcm4gaW50ICBzeXNjdGxfZGNjcF9yZXRyaWVzMTsKZGlmZiAtLWdp
dCBhL25ldC9kY2NwL291dHB1dC5jIGIvbmV0L2RjY3Avb3V0cHV0LmMKaW5kZXggNDAwYzMwYi4u
YzQ0NjBmNiAxMDA2NDQKLS0tIGEvbmV0L2RjY3Avb3V0cHV0LmMKKysrIGIvbmV0L2RjY3Avb3V0
cHV0LmMKQEAgLTE3NywxMiArMTc3LDExIEBAIHZvaWQgZGNjcF93cml0ZV9zcGFjZShzdHJ1Y3Qg
c29jayAqc2spCiAgKiBAc2s6IHNvY2tldCB0byB3YWl0IGZvcgogICogQHRpbWVvOiBmb3IgaG93
IGxvbmcKICAqLwotc3RhdGljIGludCBkY2NwX3dhaXRfZm9yX2NjaWQoc3RydWN0IHNvY2sgKnNr
LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAotCQkJICAgICAgbG9uZyAqdGltZW8pCitzdGF0aWMgaW50
IGRjY3Bfd2FpdF9mb3JfY2NpZChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2Ip
CiB7CiAJc3RydWN0IGRjY3Bfc29jayAqZHAgPSBkY2NwX3NrKHNrKTsKIAlERUZJTkVfV0FJVCh3
YWl0KTsKLQlsb25nIGRlbGF5OworCXVuc2lnbmVkIGxvbmcgZGVsYXk7CiAJaW50IHJjOwogCiAJ
d2hpbGUgKDEpIHsKQEAgLTE5MCw4ICsxODksNiBAQCBzdGF0aWMgaW50IGRjY3Bfd2FpdF9mb3Jf
Y2NpZChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IsCiAKIAkJaWYgKHNrLT5z
a19lcnIpCiAJCQlnb3RvIGRvX2Vycm9yOwotCQlpZiAoISp0aW1lbykKLQkJCWdvdG8gZG9fbm9u
YmxvY2s7CiAJCWlmIChzaWduYWxfcGVuZGluZyhjdXJyZW50KSkKIAkJCWdvdG8gZG9faW50ZXJy
dXB0ZWQ7CiAKQEAgLTE5OSwxMiArMTk2LDkgQEAgc3RhdGljIGludCBkY2NwX3dhaXRfZm9yX2Nj
aWQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQlpZiAocmMgPD0gMCkK
IAkJCWJyZWFrOwogCQlkZWxheSA9IG1zZWNzX3RvX2ppZmZpZXMocmMpOwotCQlpZiAoZGVsYXkg
PiAqdGltZW8gfHwgZGVsYXkgPCAwKQotCQkJZ290byBkb19ub25ibG9jazsKLQogCQlzay0+c2tf
d3JpdGVfcGVuZGluZysrOwogCQlyZWxlYXNlX3NvY2soc2spOwotCQkqdGltZW8gLT0gc2NoZWR1
bGVfdGltZW91dChkZWxheSk7CisJCXNjaGVkdWxlX3RpbWVvdXQoZGVsYXkpOwogCQlsb2NrX3Nv
Y2soc2spOwogCQlzay0+c2tfd3JpdGVfcGVuZGluZy0tOwogCX0KQEAgLTIxNSwxMSArMjA5LDgg
QEAgb3V0OgogZG9fZXJyb3I6CiAJcmMgPSAtRVBJUEU7CiAJZ290byBvdXQ7Ci1kb19ub25ibG9j
azoKLQlyYyA9IC1FQUdBSU47Ci0JZ290byBvdXQ7CiBkb19pbnRlcnJ1cHRlZDoKLQlyYyA9IHNv
Y2tfaW50cl9lcnJubygqdGltZW8pOworCXJjID0gLUVJTlRSOwogCWdvdG8gb3V0OwogfQogCkBA
IC0yNDAsOCArMjMxLDYgQEAgdm9pZCBkY2NwX3dyaXRlX3htaXQoc3RydWN0IHNvY2sgKnNrLCBp
bnQgYmxvY2spCiB7CiAJc3RydWN0IGRjY3Bfc29jayAqZHAgPSBkY2NwX3NrKHNrKTsKIAlzdHJ1
Y3Qgc2tfYnVmZiAqc2tiOwotCWxvbmcgdGltZW8gPSBEQ0NQX1hNSVRfVElNRU87IAkvKiBJZiBh
IHBhY2tldCBpcyB0YWtpbmcgbG9uZ2VyIHRoYW4KLQkJCQkJICAgdGhpcyB3ZSBoYXZlIG90aGVy
IGlzc3VlcyAqLwogCiAJd2hpbGUgKChza2IgPSBza2JfcGVlaygmc2stPnNrX3dyaXRlX3F1ZXVl
KSkpIHsKIAkJaW50IGVyciA9IGNjaWRfaGNfdHhfc2VuZF9wYWNrZXQoZHAtPmRjY3BzX2hjX3R4
X2NjaWQsIHNrLCBza2IpOwpAQCAtMjUxLDEwICsyNDAsOCBAQCB2b2lkIGRjY3Bfd3JpdGVfeG1p
dChzdHJ1Y3Qgc29jayAqc2ssIGludCBibG9jaykKIAkJCQlza19yZXNldF90aW1lcihzaywgJmRw
LT5kY2Nwc194bWl0X3RpbWVyLAogCQkJCQkJbXNlY3NfdG9famlmZmllcyhlcnIpK2ppZmZpZXMp
OwogCQkJCWJyZWFrOwotCQkJfSBlbHNlIHsKLQkJCQllcnIgPSBkY2NwX3dhaXRfZm9yX2NjaWQo
c2ssIHNrYiwgJnRpbWVvKTsKLQkJCQl0aW1lbyA9IERDQ1BfWE1JVF9USU1FTzsKLQkJCX0KKwkJ
CX0gZWxzZQorCQkJCWVyciA9IGRjY3Bfd2FpdF9mb3JfY2NpZChzaywgc2tiKTsKIAkJCWlmIChl
cnIpCiAJCQkJRENDUF9CVUcoImVycj0lZCBhZnRlciBkY2NwX3dhaXRfZm9yX2NjaWQiLCBlcnIp
OwogCQl9Cg==
------=_Part_22787_24118359.1165269410405--
