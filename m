From: Samuel Jero <sj323707@ohio.edu>
Date: Fri, 26 Apr 2013 18:58:39 +0000
Subject: Re: [RFC][PATCH] tfrc: Correct 2nd Loss Interval Handling
Message-Id: <517ACE5F.4080609@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enig6756107ED47B73EFAAB6E46B"
List-Id: <dccp.vger.kernel.org>
References: <516C3031.4050405@ohio.edu>
In-Reply-To: <516C3031.4050405@ohio.edu>
To: dccp@vger.kernel.org

--------------enig6756107ED47B73EFAAB6E46B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gerrit,

>>
>> [1] http://www.sjero.net/software/dccp/images/dccp_ccid3_2nd_loss_inte=
rval_bug.png
>>
> Thank you for the patch and the detailed explanation. Are there before/=
after test results
> relative to [1] which indicate that the sharp bend in the diagram is no=
w gone, or any other
> notable improvements with this fix?

An example of this same test with this fix applied is at [2]. Of course f=
or this bug to show
up as dramatically as in [1] we need to get a single loss while the conne=
ction is sending
very slowly and then not receive another loss until much later.

It's much more instructive to look at the Loss Event Rate Options the DCC=
P receiver sends.=20
(DCCP loss event rate options are sent as 1/loss_rate so a loss rate opti=
on of 33 represents
a loss rate of 1/33---1 packet out of every 33 sent)

In the buggy case we see Feedback packets with these options (each line i=
s a feedback packet)
        CCID3 Loss Event Rate: 0 (or max)
        CCID3 Loss Event Rate: 0 (or max)
        CCID3 Loss Event Rate: 33
        CCID3 Loss Event Rate: 33
 	CCID3 Loss Event Rate: 33
 	CCID3 Loss Event Rate: 33
 	CCID3 Loss Event Rate: 33
	....
	CCID3 Loss Event Rate: 33
        CCID3 Loss Event Rate: 33
        CCID3 Loss Event Rate: 18191
        CCID3 Loss Event Rate: 18191

While with my fix, we see this:
	CCID3 Loss Event Rate: 0 (or max)
        CCID3 Loss Event Rate: 0 (or max)
        CCID3 Loss Event Rate: 0 (or max)
        CCID3 Loss Event Rate: 434
        CCID3 Loss Event Rate: 434
	...
        CCID3 Loss Event Rate: 434
        CCID3 Loss Event Rate: 434
        CCID3 Loss Event Rate: 442
        CCID3 Loss Event Rate: 467
        CCID3 Loss Event Rate: 491
        CCID3 Loss Event Rate: 517
        CCID3 Loss Event Rate: 545
        CCID3 Loss Event Rate: 572
        CCID3 Loss Event Rate: 603
        CCID3 Loss Event Rate: 637

You'll notice that with this fix, the loss event rate option starts incre=
asing (i.e. the loss event
RATE decreases) after a while. This means that the 2nd loss interval has =
become large enough to=20
start effecting the loss event rate. In the buggy case, we have to wait u=
ntil that 2nd loss interval
is closed by the 2nd loss before it can effect the rate, resulting in the=
 large jump seen above.

[2] http://www.sjero.net/software/dccp/images/dccp_ccid3_2nd_loss_interva=
l_fixed.png


Samuel Jero
Masters Student
Computer Science
Internetworking Research Group
Ohio University
sj323707@ohio.edu


--------------enig6756107ED47B73EFAAB6E46B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBAgAGBQJRes5kAAoJEPUrqO1w+kIcWhkP/2eWg6NOZQG7Iqr0n6OK62Hc
YmZNMDFaqQK8p2/CmRqaTEdexUFipGFe3hdK3kLEcWBnKn5MsqxI0mLkuowDqcob
oSLvbySMrbKwLwjCeTfBk+8rHNCF0rh4WwjdSto+XqDbdRHRTQxVCTCJP1DpFJlF
mkaWiboo2T2pb2Wa/PISZ2Ewm+SY7RMMQvKxTSPeoFrDu2bUW8c99i6Elk73l0/G
IBHjNSwFUGfuRdDbdFWT34NLpxE43GU4zehOJTakHrfmlhJjYhLIxeoHi8EZQfxp
GNbRhcYwYZ/TRjSgqPpxXsBZWHMg4sgRDCjU7hRXSErMpgkRDk2cd66j2j2QgmTv
wkvAEFUZqLrvdaMCd/Ni8Vcb1FBNRqKdBWM7fO17LSfw1u5wqUGAiRIPK5Gi5Cia
jzeDHdlJ0CouILT+14Q1tTL4yUZBBtjGXBuABR6MwVPloNvR+EdhzAJLiaHgQykl
RFENDAuARpP43I0ZMqA0g0cklGcLbevwA6Tf7bbrfBxNH0dZVU3hDyn6QibDFBjB
HV006pHhagoLWqY8KDkoqUliPvXSbQLgHWCnhEJVxAQ2cppI8REZAFWGfr+gdRmL
+sR5CcF1KiG6mOQlJjYIVwa3KIn/pyUtpbzudx409vHE/UuV4ZJ+l2rtG3HxdKZS
SpFJvNUK1l25vI64xw4Z
=fA+Y
-----END PGP SIGNATURE-----

--------------enig6756107ED47B73EFAAB6E46B--
