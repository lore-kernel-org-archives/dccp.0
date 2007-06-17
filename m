From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 10:30:39 +0000
Subject: Re: [PATCH 4/6]: Simplify interface of dccp_sample_rtt
Message-Id: <200706171130.39562@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.27168@strip-the-willow>
In-Reply-To: <200706091958.27168@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [DCCP]: Simplify interface of dccp_sample_rtt
| =20
|  Don't quite understand this yet but that's just me needing to look at
|  longer I think!!
|  >
|  > +extern u32 =A0 =A0 =A0 =A0dccp_sample_rtt(struct sock *sk, long candi=
date);
|  >
|  What's candidate? Do you mean delta perhaps?
| =20
|  > +u32 dccp_sample_rtt(struct sock *sk, long delta)
|  > =A0{

Good spot - thank you. This is indeed an oversight, initially the `delta'
had been named `candidate', but I changed that later back to delta.=20

I will adapt the header file, to rename it also to `delta'.

Both are true - the `delta' is a candidate difference/ RTT-sample. If the
value is out of bounds, dccp_sample_rtt will return a value within MIN...MA=
X.

Thanks.
