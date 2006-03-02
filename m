From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Thu, 02 Mar 2006 00:48:18 +0000
Subject: Re: net-2.6.17 rebased...
Message-Id: <cbec11ac0603011648j3def242cld8b660c54258acc3@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_196_9137201.1141260498725"
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0603011628r662dbe19oc1abf02a1b6b0a2@mail.gmail.com>
In-Reply-To: <cbec11ac0603011628r662dbe19oc1abf02a1b6b0a2@mail.gmail.com>
To: dccp@vger.kernel.org

------=_Part_196_9137201.1141260498725
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

And *** again... someone pointed out my mailer is wrapping lines. I'll
go hide in the corner and beat myself up. This time attached as I
can't get gmail to defeat line wrapping. I promise I'll get it right
next patch so I don't humiliate myself quite so much next time

Dave,
If you get a chance can you push the ccid3 divide by zero fix upstream
to Linus for 2.6.16 as it has no functionality changed and eliminates
a nasty little bug...
The commit for this is b6da19617f4ab610d3d90bcbdf65fa7e2b3d7b53 in your tre=
e

I have also put at end of this e-mail after reapplying on linus tree
so above commit doesn't have fuzz...

[DCCP] ccid3: Divide by zero fix

In rare circumstances 0 is returned by dccp_li_hist_calc_i_mean which leads=
 to
a divide by zero in ccid3_hc_rx_packet_recv. Explicitly check for zero retu=
rn
now. Update copyright notice at same time.

Found by Arnaldo.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------=_Part_196_9137201.1141260498725
Content-Type: text/x-patch; name="div.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="div.diff"
X-Attachment-Id: f_ekad0t2l

ZGlmZiAtLWdpdCBhL25ldC9kY2NwL2NjaWRzL2NjaWQzLmMgYi9uZXQvZGNjcC9jY2lkcy9jY2lk
My5jCmluZGV4IGFhNjhlMGEuLjM1ZDFkMzQgMTAwNjQ0Ci0tLSBhL25ldC9kY2NwL2NjaWRzL2Nj
aWQzLmMKKysrIGIvbmV0L2RjY3AvY2NpZHMvY2NpZDMuYwpAQCAtMiw3ICsyLDcgQEAKICAqICBu
ZXQvZGNjcC9jY2lkcy9jY2lkMy5jCiAgKgogICogIENvcHlyaWdodCAoYykgMjAwNSBUaGUgVW5p
dmVyc2l0eSBvZiBXYWlrYXRvLCBIYW1pbHRvbiwgTmV3IFplYWxhbmQuCi0gKiAgQ29weXJpZ2h0
IChjKSAyMDA1IElhbiBNY0RvbmFsZCA8aWFtNEBjcy53YWlrYXRvLmFjLm56PgorICogIENvcHly
aWdodCAoYykgMjAwNS02IElhbiBNY0RvbmFsZCA8aW1jZG56bEBnbWFpbC5jb20+CiAgKgogICog
IEFuIGltcGxlbWVudGF0aW9uIG9mIHRoZSBEQ0NQIHByb3RvY29sCiAgKgpAQCAtMTAzMyw5ICsx
MDMzLDEzIEBAIHN0YXRpYyB2b2lkIGNjaWQzX2hjX3J4X3BhY2tldF9yZWN2KHN0cnUKIAlwX3By
ZXYgPSBoY3J4LT5jY2lkM2hjcnhfcDsKIAkKIAkvKiBDYWxjdWxhdGUgbG9zcyBldmVudCByYXRl
ICovCi0JaWYgKCFsaXN0X2VtcHR5KCZoY3J4LT5jY2lkM2hjcnhfbGlfaGlzdCkpCisJaWYgKCFs
aXN0X2VtcHR5KCZoY3J4LT5jY2lkM2hjcnhfbGlfaGlzdCkpIHsKKwkJdTMyIGlfbWVhbiA9IGRj
Y3BfbGlfaGlzdF9jYWxjX2lfbWVhbigmaGNyeC0+Y2NpZDNoY3J4X2xpX2hpc3QpOworCiAJCS8q
IFNjYWxpbmcgdXAgYnkgMTAwMDAwMCBhcyBmaXhlZCBkZWNpbWFsICovCi0JCWhjcngtPmNjaWQz
aGNyeF9wID0gMTAwMDAwMCAvIGRjY3BfbGlfaGlzdF9jYWxjX2lfbWVhbigmaGNyeC0+Y2NpZDNo
Y3J4X2xpX2hpc3QpOworCQlpZiAoaV9tZWFuICE9IDApCisJCQloY3J4LT5jY2lkM2hjcnhfcCA9
IDEwMDAwMDAgLyBpX21lYW47CisJfQogCiAJaWYgKGhjcngtPmNjaWQzaGNyeF9wID4gcF9wcmV2
KSB7CiAJCWNjaWQzX2hjX3J4X3NlbmRfZmVlZGJhY2soc2spOwo=
------=_Part_196_9137201.1141260498725--
