From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 16:10:06 +0000
Subject: Re: [PATCH 24/25]: Macro for moving average
Message-Id: <39e6f6c70704120910i2c59b365v828dcd65dbf39727@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_8214_27012231.1176394206875"
List-Id: <dccp.vger.kernel.org>
References: <200703211846.10823@strip-the-willow>
In-Reply-To: <200703211846.10823@strip-the-willow>
To: dccp@vger.kernel.org

------=_Part_8214_27012231.1176394206875
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 4/2/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 4/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > Quoting Ian McDonald:
> > |  > +/**
> > |  > + * Macro for exponentially weighted moving average
> > |  > + * @weight: Weight to be used as damping factor, in units of 1/10
> > |  > + * Beware that @val is evaluated multiple times.
> > |  > + */
> > |  > +#define TFRC_EWMA(val, newval, weight) \
> > |  > + val = val? ((weight) * val + (10 - (weight)) * (newval)) / 10 : (newval)
> > |  > +
> > |  Just wondering why you pass weight when you only use 9 anyway and it
> > |  just adds a step. Is it used in following patches with a different
> > |  weight?
> > |
> > In the following patches it is used one more time, which is for the `Preventing
> > Oscillations' changeset (this is not in the next patch set but in the one after that);
> > here again the weight 9/10 is used. I think it is useful to keep the `weight' argument,
> > since RFC 3448 suggests to use a different weight for the RTT sample when the `Oscillation
> > Prevention' e.g. is not deployed (a q close to zero).
> > I think it is better to keep the weight argument, it allows changing the code later, while
> > still providing the abstraction: for CCID 3 there are 4 uses of this macro alone.
> >
> OK.
>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

I don't like macros that receive as a parameter something that will be
changed, its more readable to have it as a inline function and return
the new value, even if the resulting code uses more characters, so I'm
applying the attached patch and will take care of the fallout, that is
small from what I grepped at the_whole_lot.

- Arnaldo

------=_Part_8214_27012231.1176394206875
Content-Type: text/x-patch; name=tfrc_ewma.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f0fenzzl
Content-Disposition: attachment; filename="tfrc_ewma.patch"

ZGlmZiAtLWdpdCBhL25ldC9kY2NwL2NjaWRzL2NjaWQzLmMgYi9uZXQvZGNjcC9jY2lkcy9jY2lk
My5jCmluZGV4IDk0NzQzMzEuLjQyOGFhOTIgMTAwNjQ0Ci0tLSBhL25ldC9kY2NwL2NjaWRzL2Nj
aWQzLmMKKysrIGIvbmV0L2RjY3AvY2NpZHMvY2NpZDMuYwpAQCAtMTgzLDcgKzE4Myw3IEBAIHN0
YXRpYyBpbmxpbmUgdm9pZCBjY2lkM19oY190eF91cGRhdGVfcyhzdHJ1Y3QgY2NpZDNfaGNfdHhf
c29jayAqaGN0eCwgaW50IGxlbikKIHsKIAljb25zdCB1MTYgb2xkX3MgPSBoY3R4LT5jY2lkM2hj
dHhfczsKIAotCWhjdHgtPmNjaWQzaGN0eF9zID0gb2xkX3MgPT0gMCA/IGxlbiA6ICg5ICogb2xk
X3MgKyBsZW4pIC8gMTA7CisJaGN0eC0+Y2NpZDNoY3R4X3MgPSB0ZnJjX2V3bWEoaGN0eC0+Y2Np
ZDNoY3R4X3MsIGxlbiwgOSk7CiAKIAlpZiAoaGN0eC0+Y2NpZDNoY3R4X3MgIT0gb2xkX3MpCiAJ
CWNjaWQzX3VwZGF0ZV9zZW5kX2ludGVydmFsKGhjdHgpOwpAQCAtNDc0LDggKzQ3NCw3IEBAIHN0
YXRpYyB2b2lkIGNjaWQzX2hjX3R4X3BhY2tldF9yZWN2KHN0cnVjdCBzb2NrICpzaywgc3RydWN0
IHNrX2J1ZmYgKnNrYikKIAkgKgogCSAqIHEgaXMgYSBjb25zdGFudCwgUkZDIDM0NDggcmVjb21t
ZW5kcyAwLjkKIAkgKi8KLQloY3R4LT5jY2lkM2hjdHhfcnR0ID0gaGN0eC0+Y2NpZDNoY3R4X3J0
dCA9PSAwID8gIHJfc2FtcGxlCi0JCQkgICAgOiAoOSAqIGhjdHgtPmNjaWQzaGN0eF9ydHQgKyBy
X3NhbXBsZSkgLyAxMDsKKwloY3R4LT5jY2lkM2hjdHhfcnR0ID0gdGZyY19ld21hKGhjdHgtPmNj
aWQzaGN0eF9ydHQsIHJfc2FtcGxlLCA5KTsKIAogCS8qCiAJICogVXBkYXRlIGFsbG93ZWQgc2Vu
ZGluZyByYXRlIGFzIHBlciBkcmFmdCByZmMzNDQ4YmlzLCA0LjIvNC4zCkBAIC03MjQsOCArNzIz
LDcgQEAgc3RhdGljIGlubGluZSB2b2lkIGNjaWQzX2hjX3J4X3VwZGF0ZV9zKHN0cnVjdCBjY2lk
M19oY19yeF9zb2NrICpoY3J4LCBpbnQgbGVuKQogCWlmICh1bmxpa2VseShsZW4gPT0gMCkpCS8q
IGRvbid0IHVwZGF0ZSBvbiBlbXB0eSBwYWNrZXRzIChlLmcuIEFDS3MpICovCiAJCWNjaWQzX3By
X2RlYnVnKCJQYWNrZXQgcGF5bG9hZCBsZW5ndGggaXMgMCAtIG5vdCB1cGRhdGluZ1xuIik7CiAJ
ZWxzZQotCQloY3J4LT5jY2lkM2hjcnhfcyA9IGhjcngtPmNjaWQzaGNyeF9zID09IDAgPyBsZW4g
OgotCQkJCSAgICAoOSAqIGhjcngtPmNjaWQzaGNyeF9zICsgbGVuKSAvIDEwOworCQloY3J4LT5j
Y2lkM2hjcnhfcyA9IHRmcmNfZXdtYShoY3J4LT5jY2lkM2hjcnhfcywgbGVuLCA5KTsKIH0KIAog
c3RhdGljIHZvaWQgY2NpZDNfaGNfcnhfc2VuZF9mZWVkYmFjayhzdHJ1Y3Qgc29jayAqc2spCmRp
ZmYgLS1naXQgYS9uZXQvZGNjcC9jY2lkcy9saWIvdGZyYy5oIGIvbmV0L2RjY3AvY2NpZHMvbGli
L3RmcmMuaAppbmRleCBmYWY1ZjdlLi5mMjZlOWU5IDEwMDY0NAotLS0gYS9uZXQvZGNjcC9jY2lk
cy9saWIvdGZyYy5oCisrKyBiL25ldC9kY2NwL2NjaWRzL2xpYi90ZnJjLmgKQEAgLTM3LDYgKzM3
LDE3IEBAIHN0YXRpYyBpbmxpbmUgdTMyIHNjYWxlZF9kaXYzMih1NjQgYSwgdTMyIGIpCiAJcmV0
dXJuIHJlc3VsdDsKIH0KIAorLyoqCisgKiBFeHBvbmVudGlhbGx5IHdlaWdodGVkIG1vdmluZyBh
dmVyYWdlCisgKiBAd2VpZ2h0OiBXZWlnaHQgdG8gYmUgdXNlZCBhcyBkYW1waW5nIGZhY3Rvciwg
aW4gdW5pdHMgb2YgMS8xMAorICovCitzdGF0aWMgaW5saW5lIHUzMiB0ZnJjX2V3bWEoY29uc3Qg
dTMyIHZhbCwgY29uc3QgdTMyIG5ld3ZhbCwgY29uc3QgdTggd2VpZ2h0KQoreworCWlmICh2YWwg
IT0gMCkKKwkJcmV0dXJuICh3ZWlnaHQgKiB2YWwgKyAoMTAgLSB3ZWlnaHQpICogbmV3dmFsKSAv
IDEwOyAKKwlyZXR1cm4gbmV3dmFsOworfQorCiBleHRlcm4gdTMyIHRmcmNfY2FsY194KHUxNiBz
LCB1MzIgUiwgdTMyIHApOwogZXh0ZXJuIHUzMiB0ZnJjX2NhbGNfeF9yZXZlcnNlX2xvb2t1cCh1
MzIgZnZhbHVlKTsKIAo=
------=_Part_8214_27012231.1176394206875--
